var express = require('express');
const {
    cp
} = require('fs');
var app = express();
var server = require('http').createServer(app);
var io = require('socket.io')(server);


let ON_CONNECTION = 'connection';
let ON_DISCONNECT = 'disconnect';

let EVENT_IS_USER_ONLINE = 'check_online';
let EVENT_SINGLE_CHAT_MESSAGE = 'single_chat_message';

let SUB_EVENT_RECEIVE_MESSAGE = 'receive_message';
let SUB_EVENT_IS_USER_CONNECTED = 'is_user_connected';

let STATUS_MESSAGE_NOT_SENT = 10001;
let STATUS_MESSAGE_SENT = 10002;

let listen_port = 6000;

server.listen(listen_port);

const userMap = new Map();

io.sockets.on(ON_CONNECTION, function (socket) {
    onEachUserConnection(socket);
});

function onEachUserConnection(socket) {
    print('------------');
    print('Connected => Socket ID: ' + socket.id + ', User: ' + stringifyToJson(socket.handshake.query));
    var from_user_id = socket.handshake.query.from;
    let userMapVal = {
        socket_id: socket.id
    };
    addUserToMap(from_user_id, userMapVal);
    print(userMap);
    printOnlineUsers();

    onMessage(socket);
    checkOnline(socket);
    onDisconnect(socket);

}

function onMessage(socket) {
    socket.on(EVENT_SINGLE_CHAT_MESSAGE, function (chat_message) {
        singleChatHandler(socket, chat_message);
    });
}

function checkOnline(socket) {
    socket.on(EVENT_IS_USER_ONLINE, function (chat_user_details) {
        onlineCheckHandler(socket, chat_user_details);
    });
}

function onlineCheckHandler(socket, chat_user_details) {
    let to_user_id = chat_user_details.to;
    print('Checking Online User => ' + to_user_id);
    let to_user_socket_id = getSocketIDFromMapForThisUser(to_user_id);
    print('Online Socket ID: ' + to_user_socket_id);
    let isOnline = undefined != to_user_socket_id;
    chat_user_details.to_user_online_status = isOnline;
    sendBackToClient(socket, SUB_EVENT_IS_USER_CONNECTED, chat_user_details);
}

function sendBackToClient(socket, event, chat_message) {
    socket.emit(event, stringifyToJson(chat_message));
}

function singleChatHandler(socket, chat_message) {
    print('onMessage: ' + stringifyToJson(chat_message));
    let to_user_id = chat_message.to;
    let from_user_id = chat_message.from;
    print(from_user_id + '=> ' + to_user_id);
    let to_user_socket_id = getSocketIDFromMapForThisUser(to_user_id);
    if (to_user_socket_id == undefined) {
        print('Chat user not connected');
        chat_message.to_user_online_status = false;
        return;
    }
    chat_message.to_user_online_status = true;
    sendToConnectedSocket(socket, to_user_socket_id, SUB_EVENT_RECEIVE_MESSAGE, chat_message);
}

function sendToConnectedSocket(socket, to_user_socket_id, event, chat_message) {
    socket.to(`${to_user_socket_id}`).emit(event, stringifyToJson(chat_message));
}


function getSocketIDFromMapForThisUser(to_user_id) {
    let userMapVal = userMap.get(`${to_user_id}`);
    if (undefined == userMapVal) {
        return undefined;
    }
    return userMapVal.socket_id;
}

function removeUserwithSocketIDFromMap(socket_id) {
    print('Deleting User:  ' + socket_id);
    let toDeleteUser;
    for (let key of userMap) {
        let userMapValue = key[1];
        if (userMapValue.socket_id == socket_id){
            toDeleteUser = key[0];
        }

    }
    print('Deleting user: '+ toDeleteUser);
    if(undefined != toDeleteUser) {
        userMap.delete(toDeleteUser);
    }
    print(userMap);
    printOnlineUsers();
}

function onDisconnect(socket) {
    socket.on(ON_DISCONNECT, function () {
        print('Disconnected ' + socket.id);
        removeUserwithSocketIDFromMap(socket.id);
        socket.removeAllListeners(SUB_EVENT_RECEIVE_MESSAGE);
        socket.removeAllListeners(SUB_EVENT_IS_USER_CONNECTED);
        socket.removeAllListeners(ON_DISCONNECT);
    });
}

function addUserToMap(key_user_id, socket_id) {
    userMap.set(key_user_id, socket_id);
}

function printOnlineUsers() {
    print('Online Users: ' + userMap.size);
}

function print(txt) {
    console.log(txt);
}

function stringifyToJson(data) {
    return JSON.stringify(data);
}