import {User} from "./User";
import {v4 as uuidv4} from 'uuid';
import {Message} from "./Message";

export class Room {
    uuid: string;
    users: User[];
    name: string;
    hasStarted : boolean;

    constructor(args: {name: string}) {
        this.name = args.name
        this.uuid = uuidv4()
        this.hasStarted = false;
        this.users = [];
    }

    /**
     * Add user to the room if the game is not started
     * @param user
     */
    addUser(user: User): boolean {
        if(!this.hasStarted){
            this.users.push(user)
            return true;
        } else {
            return false;
        }
    }

    async sendMessage(message: Message) {
        for(let user of this.users){
            user.gameWebsocket.send(JSON.stringify(message))
        }

    }
}