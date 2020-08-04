//start our server
import {kPort} from "./config/config";
import {server} from "./app";

server.listen(kPort, () => {
    console.log(`server start`);
});