import * as request from "supertest";
import {app, roomList, userList} from "../../app";
import {Room} from "../Room";
import {User} from "../User";


describe("Test Room", () => {
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
        room.game = {
            category: "a",
            words: [{word: "a", hints: [], category: "a"}, {word: "b", hints: [], category: "a"}, {
                word: "c",
                hints: [],
                category: "a"
            }]
        }

        room.randomizeWord()
        expect(room.game.words.length).toBe(3)
    })
});