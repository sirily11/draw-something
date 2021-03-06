import * as express from 'express';
import * as http from 'http';
import * as cors from "cors"
import * as enableWs from 'express-ws'
import {kPort} from "./config/config";
import {homeRouter} from "./routers/home_routers";
import {User} from "./models/User";
import {userRouter} from "./routers/user_router";
import * as url from "url";
import {Room} from "./models/Room";


export const {app, getWss, applyTo} = enableWs(express());
app.use(express.json());
app.use(cors());
//routers
app.use(homeRouter);
app.use(userRouter);

//initialize a simple http server
export const server = http.createServer(app);
//initialize the WebSocket server instance
export const userList: User[] = [];
export const roomList: Room[] = [];


app.ws('/', (ws, req) => {
    let uuid = ""
    if (req.url) {
        let query = url.parse(req.url, true).query
        uuid = query.uuid?.toString()
        let username = query.name?.toString()
        if (uuid && username) {
            let user = new User({name: username, uuid: uuid, point: 0})
            user.roomWebsocket = ws;
            userList.push(user)
            console.info(`Connect user ${uuid}. Total users: ` + userList.length)
            user.sendRoomMessage(roomList)
        } else {
            console.error("Invalid url")
        }
    }

    ws.on("error", (err) => {
        console.log(err)
    })

    ws.on('close', () => {
        console.log("close", uuid)
        let index = userList.findIndex((u) => u.uuid === uuid);
        if (index > -1) {
            userList.splice(index, 1);
        }
    });
})


app.ws("/game", async (ws, req) => {
    let foundRoom: Room;
    let room: any;
    let user: string;

    if (req.url) {
        let query = url.parse(req.url, true).query
        user = query.user as string
        room = query.room
        let foundUser = userList.find((u) => u.uuid === user)
        foundRoom = roomList.find((r) => r.uuid === room)
        if (foundRoom && foundUser) {
            foundUser.gameWebsocket = ws;
            foundRoom.addUser(foundUser)
            foundRoom.notifyRoomStatus();
            console.info(`Room ${room} has users: ${foundRoom.users.length}`)
        } else {
            console.error("Cannot found room and user")
        }
    }

    ws.on("message", (msg: string) => {
        let m = JSON.parse(msg)
        let r = roomList.find((r) => r.uuid)
        if (r) {
            r.sendMessage(m);
        }
    })

    ws.on("close", () => {
        console.info("Close game")
        let index = foundRoom?.users?.findIndex((u) => u.uuid === user) ?? -1
        if (index > -1) {
            foundRoom.users.splice(index, 1)
            foundRoom.notifyRoomStatus();
        }
    })
})
