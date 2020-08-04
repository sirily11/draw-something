import {User} from "./User";
import {v4 as uuidv4} from 'uuid';
import {Message} from "./Message";
import {kTimePerGame} from "../config/config";
import {Game} from "./tests/Word";
import Axios from "axios";
import * as fs from "fs";

function getRandomArbitrary(min: number, max: number) {
    return Math.random() * (max - min) + min;
}

export class Room {
    uuid: string;
    users: User[];
    name: string;
    hasStarted: boolean;
    private timer: NodeJS.Timeout
    timeRemaining: number;
    currentWordIndex: number;
    game: Game

    constructor(args: { name: string }) {
        this.name = args.name
        this.uuid = uuidv4()
        this.hasStarted = false;
        this.users = [];
        this.currentWordIndex = 0;
        this.timeRemaining = kTimePerGame;
    }

    /**
     * Select game
     * @param url
     */
    async selectGame(url: string) {
        if (process.env.local) {
            // @ts-ignore
            this.game = JSON.parse(fs.readFileSync(''))
        } else {
            this.game = await Axios.get(url);
        }
    }

    private timeCallback = () => {
        this.timeRemaining = this.timeRemaining - 1;
        let word = this.game.words[this.currentWordIndex]
        // Send message about time remaining
        this.sendMessage({type: "room", content: {...this.toJson(), word: word.word}})
        // send message about hint
        let hint = word.hints.find((h) => h.timeShowAt === this.timeRemaining)
        if (hint) {
            this.sendMessage({type: "word", content: {word: word.category, hint: hint.title}})
        }
        // when time is up
        if (this.timeRemaining === 0) {
            // last word
            if (this.currentWordIndex === this.game.words.length - 1) {
                this.stopGame();
            } else {
                window.clearInterval(this.timer)
            }
        }
    }

    /**
     * Randomize words
     * @private
     */
    randomizeWord() {
        let newGame: Game = {words: [], category: this.game.category}
        let words = this.game.words;
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
    startGame() {
        this.randomizeWord()
        this.hasStarted = true;
        this.timer = setInterval(this.timeCallback, 1000);
    }

    async nextWord() {
        this.currentWordIndex += 1;
        this.timer = setInterval(this.timeCallback, 1000);
    }

    stopGame() {
        window.clearInterval(this.timer)
        this.currentWordIndex = 0;
        this.timeRemaining = kTimePerGame;
        this.currentWordIndex = 0;
        // send message
        this.sendMessage({type: "room", content: {...this.toJson(), word: undefined}})
    }

    /**
     * Add user to the room if the game is not started
     * @param user
     */
    addUser(user: User): boolean {
        if (!this.hasStarted) {
            this.users.push(user)
            return true;
        } else {
            return false;
        }
    }

    sendMessage(message: Message) {
        console.log("send message", message)
        for (let user of this.users) {
            user.gameWebsocket.send(JSON.stringify(message))
        }
    }

    toJson() {
        return {
            hasStarted: this.hasStarted,
            users: this.users.map((u) => u.toJson()),
            timeRemaining: this.timeRemaining,
            name: this.name,
        }
    }
}