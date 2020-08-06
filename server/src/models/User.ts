import {v4 as uuidv4} from 'uuid';
import * as WebSocket from 'ws';
import {Message} from "./Message";
import {Room} from "./Room";

export interface IUser {
    name: string;
    uuid?: string;
    point?: number;
}


export class User implements IUser {

    point: number;

    /**
     * user's name
     */
    name: string;
    /**
     * User's id
     */
    uuid: string;
    /**
     * Game's websocket. Get game's detail
     */
    gameWebsocket?: WebSocket;
    /**
     * Room's websocket. Get list of room
     */
    roomWebsocket?: WebSocket;

    constructor(args: IUser) {
        if (args.name) {
            this.name = args.name;
            this.uuid = args.uuid ? args.uuid : uuidv4();
            this.point = 0;
        } else {
            throw "User name should not be null"
        }

    }

    startGame() {
        this.point = 0;
    }

    endGame() {
        this.point = 0;
    }

    sendRoomMessage(message: Room[]) {
        if (this.roomWebsocket?.readyState === 1)
            this.roomWebsocket?.send(JSON.stringify(message.map((r) => r.toJson())))
    }

    sendGameMessage(message: Message) {
        if (this.gameWebsocket?.readyState === 1) {
            this.gameWebsocket.send(JSON.stringify(message))
        }

    }

    toJson(): IUser {
        return {
            name: this.name,
            uuid: this.uuid,
            point: this.point,
        };
    }
}