import {User} from "./User";
import {v4 as uuidv4} from 'uuid';
import {Command, Message, RoomMessage} from "./Message";
import {kTimePerGame, kWaitTime} from "../config/config";
import {Game} from "./tests/Word";
import Axios from "axios";
import * as fs from "fs";
import {roomList, userList} from "../app";
import {game} from "../game";

function getRandomArbitrary(min: number, max: number) {
    return Math.random() * (max - min) + min;
}

export class Room {
    uuid: string;
    users: User[];
    readyUsers: User[];
    name: string;
    hasStarted: boolean;
    private timer: NodeJS.Timeout
    timeRemaining: number;
    currentWordIndex: number;
    game: Game
    currentUserIndex: number;
    currentUser: User;

    constructor(args: { name: string }) {
        this.name = args.name
        this.uuid = uuidv4()
        this.hasStarted = false;
        this.users = [];
        this.currentWordIndex = 0;
        this.timeRemaining = kTimePerGame;
        this.readyUsers = [];
        this.game = game;
        this.currentUserIndex = 0;
    }

    /**
     * Select game
     * @param url
     */
    public async selectGame(url: string) {
        if (process.env.local) {
            // @ts-ignore
            this.game = JSON.parse(fs.readFileSync(''))
        } else {
            this.game = await Axios.get(url);
        }
    }

    /**
     * A timer callback, will send room message and word message
     * based on the time remaining
     */
    timeCallback = (): Message[] => {
        let messages: Message[] = [];
        this.timeRemaining = this.timeRemaining - 1;
        let word = this.game.words[this.currentWordIndex]
        // Send message about time remaining
        messages.push({type: "room", content: {...this.toJson(), word: word?.word}})
        this.sendMessage(messages[messages.length - 1])
        // send message about hint
        let hint = word.hints.find((h) => h.timeShowAt === this.timeRemaining)
        if (hint) {
            messages.push({type: "word", content: {word: word.category, hint: hint.title}})
            this.sendMessage(messages[messages.length - 1])
        }
        // when time is up
        if (this.timeRemaining === 0) {
            // last word
            if (this.currentWordIndex >= this.game.words.length - 1) {
                this.stopGame();
            } else if (this.currentUserIndex >= this.users.length - 1) {
                this.stopGame();
            } else {
                clearInterval(this.timer)
                setTimeout(() => {
                    this.nextWord();
                }, kWaitTime * 1000)

            }
        }
        return messages;
    }

    /**
     * Randomize words
     * @private
     */
    public randomizeWord() {
        let newGame: Game = {words: [], category: this.game?.category}
        let words = this.game?.words ?? [];
        while (words.length > 0) {
            let randomNumber = getRandomArbitrary(0, words.length)
            let word = words.splice(randomNumber, 1)
            newGame.words.push(word[0])
        }
        this.game = newGame;
    }

    /**
     * Start game
     */
    public startGame() {
        this.randomizeWord()
        this.readyUsers = [];
        this.hasStarted = true;
        this.currentWordIndex = 0;
        this.timeRemaining = kTimePerGame;
        this.timer = setInterval(this.timeCallback, 1000);
        this.currentUserIndex = 0;
        this.currentUser = this.users[this.currentUserIndex]
        this.sendClearMessage()
    }

    /**
     * Next word
     */
    public nextWord() {
        this.sendClearMessage()
        this.currentWordIndex += 1;
        this.currentUserIndex += 1;
        this.timeRemaining = kTimePerGame;
        this.currentUser = this.users[this.currentUserIndex]
        this.timer = setInterval(this.timeCallback, 1000);
    }

    /**
     * Stop the game.
     */
    public stopGame() {
        clearInterval(this.timer)
        this.currentWordIndex = 0;
        this.timeRemaining = kTimePerGame;
        this.currentWordIndex = 0;
        this.currentUser = undefined;
        this.hasStarted = false;
        // send message
        this.sendMessage({type: "room", content: {...this.toJson(), word: undefined}})
    }

    /**
     * Add user to the room if the game is not started
     * @param user
     */
    public addUser(user: User): boolean {
        if (!this.hasStarted) {
            let found = this.users.findIndex((u) => u.uuid === user.uuid)
            if (found === -1) {
                this.users.push(user)
            } else {
                this.users[found] = user;
            }
            return true;
        } else {
            return false;
        }
    }

    public sendClearMessage() {
        let message: Command = {command: "clear", user: undefined}
        this.sendMessage({type: "command", content: message})
    }

    /**
     * Send each user about current room status.
     * Call this before the game starts
     */
    public notifyRoomStatus() {
        let message: RoomMessage = this.toJson()
        userList.forEach((u) => u.sendRoomMessage(roomList))
        this.users.forEach((u) => u.sendGameMessage({type: "room", content: message}));

    }

    /**
     * Send message to all clients
     * @param message
     */
    public sendMessage(message: Message) {
        console.log("send message", message)
        for (let user of this.users) {
            user.sendGameMessage(message)
        }
    }

    public ready(user: User) {
        let foundUser = this.readyUsers.find((u) => u.uuid === user.uuid)
        if (!foundUser) {
            this.readyUsers.push(user);
            if (this.readyUsers.length === this.users.length) {
                this.startGame()
            }
            this.notifyRoomStatus();
        }
    }

    public notReady(user: User) {
        let index = this.readyUsers.findIndex((u) => u.uuid === user.uuid)
        if (index > -1) {
            this.readyUsers.splice(index, 1)
            this.notifyRoomStatus();
        }
    }

    public toJson() {
        return {
            hasStarted: this.hasStarted,
            users: this.users.map((u) => u.toJson()),
            timeRemaining: this.timeRemaining,
            name: this.name,
            room: this.uuid,
            readyUsers: this.readyUsers.map((u) => u.toJson()),
            currentUser: this.currentUser?.toJson(),
        }
    }
}