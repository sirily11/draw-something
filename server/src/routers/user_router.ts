import * as express from 'express';
import * as cors from "cors";
import {userList} from "../app";
import {User} from "../models/User";

export const userRouter = express.Router();
userRouter.use(express.json());
userRouter.use(cors());

userRouter.post('/login', async (req, res) => {
    let data = req.body;
    try {
        let user = new User(data)
        res.status(200).send(user.toJson())
    } catch (err) {
        res.status(500).send({err: err})
    }
})