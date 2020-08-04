import * as express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import * as cors from "cors"
import {kPort} from "./config/config";
import {homeRouter} from "./routers/home_routers";
import {User} from "./models/User";
import {userRouter} from "./routers/user_router";
import * as url from "url";
import {Room} from "./models/Room";


export const app = express();
app.use(express.json());
app.use(cors());
//routers
app.use(homeRouter);
app.use(userRouter);
//initialize a simple http server
export const server = http.createServer(app);
//initialize the WebSocket server instance
const roomWebsocket = new WebSocket.Server({server: server, path: ""});
const gameWebsocket = new WebSocket.Server({server: server, path: "/game"});
export const userList: User[] = [];
export const roomList: Room[] = [];

roomWebsocket.on('connection', async (ws, req) => {
    let uuid = ""
    if (req.url) {
        let query = url.parse(req.url, true).query
        uuid = query.uuid?.toString()
        let username = query.name?.toString()
        if (uuid && username) {
            let user = new User({name: username, uuid: uuid, point: 0})
            user.roomWebsocket = ws;
            userList.push(user)
            console.info("Connect user. Total users: " + userList.length)

        } else{
            console.error("Invalid url")
        }
    }
    ws.on('close', () => {
        let index = userList.findIndex((u) => u.uuid === uuid);
        if (index > -1) {
            userList.splice(index, 1);
        }
    });
})

