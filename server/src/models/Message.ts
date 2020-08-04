import {IUser} from "./User";


export interface Message{
    type: "draw" | "chat" | "system" | "user"
    content: DrawMessage | ChatMessage | SystemMessage | RoomMessage | WordMessage | TimeMessage
}

/**
 * Information about drawing
 */
interface DrawMessage{
    x: any;
    y: any;
    user: IUser;
}

/**
 * Information about time remaining
 */
interface TimeMessage{
    timeRemaining: number;
}

/**
 * Information about current words and its hint
 */
interface WordMessage{
    word: string;
    hint: string;
}

/**
 * Information about chatting
 */
interface ChatMessage{
    user: IUser;
    message: string
}

/**
 * Information about system
 */
interface SystemMessage{
    message: string;
}

/**
 * Information about current users in the room
 */
interface RoomMessage{
    users: IUser[]

}