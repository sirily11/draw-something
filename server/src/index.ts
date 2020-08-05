//start our server
import {kPort} from "./config/config";
import {server, app} from "./app";
import {Room} from "./models/Room";
import {game} from "./game";


let room = new Room({name: "Hello"})
room.game = game
// room.startGame()

app.listen(kPort, ()=>{
    console.log("Server start")
})