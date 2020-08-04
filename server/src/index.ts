//start our server
import {kPort} from "./config/config";
import {server} from "./app";
import {Room} from "./models/Room";


let room = new Room({name: "Hello"})
room.game = {
    category: "test",
    words: [
        {
            word: "A",
            category: 'Car',
            hints: [{
                title: "A car",
                timeShowAt: 55,
            }, {
                title: "B car",
                timeShowAt: 50,
            }]
        }
    ]
}
room.startGame()

// server.listen(kPort, () => {
//     console.log(`server start`);
// });