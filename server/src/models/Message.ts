import {IUser, User} from "./User";


export interface Message {
    type: "draw" | "chat" | "system" | "room" | "word" | "command"
    content: DrawMessage | ChatMessage | SystemMessage | RoomMessage | WordMessage | Command
}

export interface Command {
    command: "clear" | "redo" | "undo";
    user: IUser
}

/**
 * Information about drawing
 */
interface DrawMessage {
    offsets: {
        dx: number,
        dy: number,
    }[],
    color: {
        red: number,
        green: number,
        blue: number,
        opacity: number,
    }
    user: IUser;
}

/**
 * Information about current words and its hint
 */
interface WordMessage {
    word: string;
    hint: string;
}

/**
 * Information about chatting
 */
interface ChatMessage {
    user: IUser;
    message: string
}

/**
 * Information about system
 */
interface SystemMessage {
    message: string;
}

/**
 * Information about current users in the room
 */
export interface RoomMessage {
    users: IUser[]
    name: string;
    hasStarted: boolean;
    timeRemaining: number;
    word?: string;
}