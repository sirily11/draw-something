import {User} from "../User";
import * as request from "supertest";
import {app} from "../../app";

describe("Test user", () => {
    test("Create user", () => {
        const user = new User({name: "Hello"});
        expect(user.name).toBeDefined();
    });

    test('Create user request without username', async () => {
        let res = await request(app).post('/login')
        expect(res.status).toBe(500)
    })

    test('Create user request', async () => {
        let res = await request(app)
            .post('/login',)
            .send({username: 'test'})
        expect(res.status).toBe(500)
    })
});