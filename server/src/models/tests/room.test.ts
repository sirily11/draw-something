import * as request from "supertest";
import {app, roomList, userList} from "../../app";
import {Room} from "../Room";
import {User} from "../User";
import {Game} from "../Word";
import {ChatMessage, RoomMessage} from "../Message";


describe("Test Room", () => {
    let game: Game;

    beforeEach(() => {
        game = {
            category: "a",
            words: [{
                word: "a", hints: [{
                    title: "A car",
                    timeShowAt: 55,
                }], category: "a"
            },
                {word: "b", hints: [], category: "a"},
                {
                    word: "c",
                    hints: [],
                    category: "a"
                }]
        };
    })


    afterEach(() => {
        while (roomList.length > 0) {
            roomList.pop();
        }
        while (userList.length > 0) {
            userList.pop()
        }
    })

    test('Create Room', async () => {
        let res = await request(app)
            .post('/room',)
            .send({name: 'test'})
        expect(res.status).toBe(200)

        let res2 = await request(app)
            .post('/room',)
            .send({name: 'test'})
        expect(res2.status).toBe(500)
    })

    test('Delete Room', async () => {
        let room = new Room({name: "test"})
        roomList.push(room)
        let res = await request(app)
            .delete('/room?room=' + room.uuid,)
        expect(res.status).toBe(301)
        expect(roomList.length).toBe(0)
    })

    test("Join room started", async () => {
        let room = new Room({name: "test"});
        let user = new User({name: "a"})

        room.hasStarted = true;
        roomList.push(room)
        userList.push(user)
        let res = await request(app)
            .post(`/join-room?room=${room.uuid}&user=${user.uuid}`)
        expect(res.status).toBe(500)
    })

    test("Join room not started", async () => {
        let room = new Room({name: "test"});
        let user = new User({name: "a"})

        room.hasStarted = false;
        roomList.push(room)
        userList.push(user)
        let res = await request(app)
            .post(`/join-room?room=${room.uuid}&user=${user.uuid}`)
        expect(res.status).toBe(200)
    })

    test("Random word", async () => {
        let room = new Room({name: "test"});
        room.game = game;

        room.randomizeWord()
        expect(room.game.words.length).toBe(3)
    })

    test("Test timer callback", async () => {
        let room = new Room({name: "Hello world"})
        room.timeRemaining = 60;
        room.game = game;

        let messages = room.timeCallback()
        expect(messages.length).toBe(1)
        expect(messages[0].type).toBe("room")
        expect((messages[0].content as RoomMessage).word).toBe('a')
    })

    test("Test timer callback 2", () => {
        let room = new Room({name: "Hello world"})
        room.timeRemaining = 56;
        room.game = game;

        let messages = room.timeCallback()
        expect(messages.length).toBe(2)
        expect(messages[0].type).toBe("room")
        expect(messages[1].type).toBe("word")
    })

    test("Test timer callback 3 with next word", () => {
        let room = new Room({name: "Hello world"})
        room.timeRemaining = 56;
        room.game = game;
        room.nextWord()
        let messages = room.timeCallback()
        expect(messages.length).toBe(1)
        expect(messages[0].type).toBe("room")
        expect((messages[0].content as RoomMessage).word).toBe('b')
    })

    test("Start a game", ()=>{
        let room = new Room(({name: "Hello world"}))
        room.game = game
        let user = new User({name: "Test"})
        let user2 = new User({name: "Test2"})
        room.addUser(user)
        room.addUser(user2)
        room.ready(user)
        expect(room.hasStarted).toBeFalsy()
        room.ready(user2)
        expect(room.hasStarted).toBeTruthy()
    })

    test("Send message", () =>{
        let room = new Room(({name: "Hello world"}));
        room.game = game;
        room.hasStarted = true
        let result = room.sendMessage({ type: "chat", content: {message: "a"} });
        expect((result.content as ChatMessage).message).toBe("****")
        let result2 = room.sendMessage({ type: "chat", content: {message: "A"} });
        expect((result2.content as ChatMessage).message).toBe("****")
        let result3 = room.sendMessage({ type: "chat", content: {message: "b"} });
        expect((result3.content as ChatMessage).message).toBe("b")
    })
});