import * as express from 'express';
import * as cors from "cors";
import {Room} from "../models/Room";
import {roomList, userList} from "../app";

export const homeRouter = express.Router();
homeRouter.use(express.json());
homeRouter.use(cors());

// create room
homeRouter.post('/room', async (req, res) => {
    let name = req.body.name
    let room = new Room({name: name});
    let find = roomList.find((r) => r.name === name)
    if (roomList.length === 10) {
        res.send(500).send({"error": "too many room"})
        return;
    }
    if (!find) {
        roomList.push(room)
        userList.forEach((u) => u.sendRoomMessage(roomList))
        res.status(200).send({'status': "ok"})
    } else {
        res.status(500).send({"error": "Name exists"})
    }
})

// delete room
homeRouter.delete('/room', async (req, res) => {
    let uuid = req.query.room;
    let roomIndex = roomList.findIndex((r) => r.uuid === uuid);
    if (roomIndex > -1) {
        roomList.splice(roomIndex, 1)
        userList.forEach((u) => u.sendRoomMessage(roomList))
        res.status(301).send({"status": "Deleted"})
    } else {
        res.status(404).send({"error": "Cannot delete"})
    }
})

homeRouter.post('/join-room', async (req, res) => {
        let roomId = req.query.room
        let userId = req.query.user
        if (roomId === undefined || userId === undefined) {
            res.status(404).send({"error": "Room ID and uuid should be defined"})
        }
        let room = roomList.find((r) => r.uuid === roomId);
        let user = userList.find((u) => u.uuid === userId);

        if (room && user) {
            let success = room.hasStarted !== true
            if (success) {
                res.status(200).send({"status": "success"})
                return;
            } else {
                res.status(500).send({"error": "The game has started"})
                return;
            }

        } else {
            res.status(400).send({"error": "Cannot find room or user"})
        }
    }
)

homeRouter.post("/start-game", async (req, res) => {
    let uuid = req.query.user;
    let roomId = req.query.room;
    let foundUser = userList.find((u) => u.uuid === uuid)
    let foundRoom = roomList.find((r) => r.uuid === roomId)
    if (foundUser && foundRoom) {
        foundRoom.ready(foundUser)
        res.status(200).send({status: "ok"})
        return;
    } else {
        res.status(404).send({error: "Cannot find user"})
        return;
    }

})

homeRouter.delete("/start-game", async (req, res) => {
    let uuid = req.query.user;
    let roomId = req.query.room;
    let foundUser = userList.find((u) => u.uuid === uuid)
    let foundRoom = roomList.find((r) => r.uuid === roomId)
    if (foundUser && foundRoom) {
        foundRoom.notReady(foundUser)
        res.status(301).send({status: "ok"})
    } else {
        res.status(404).send({status: "error"})
    }
})