# Hubot Sococo Adapter

A Hubot adapter to connect bots to the Sococo chat service.

## Installation and Setup

To get your own hubot up and running we recommend following the [Getting Started](https://github.com/github/hubot/tree/master/docs) directions from the hubot wiki, they are summarized here:

Linux/OSX

    % npm install -g hubot coffee-script
    % hubot --create myhubot
    % cd myhubot
    % npm install hubot-sococo --save && npm install

Windows

    npm install -g hubot coffee-script
    hubot --create myhubot
    cd myhubot
    npm install hubot-sococo --save && npm install


## Configuring the Adapter

The Sococo adapter requires only the following environment variables.

* `HUBOT_SOCOCO_SERVER`
* `HUBOT_SOCOCO_TOKEN`
* `HUBOT_SOCOCO_ROOMCODE`

### Sococo Server

This is the full hostname or IP address of the Sococo chat server you want your hubot
to connect to. Make a note of it.

### Sococo Token

This is the token generated for your bot from the Sococo website.

### Sococo Room Code

This is the last portion of a room code that is used for Guest Access meetings.   To get the room code for a room, right click on the room and click "Copy Link" then strip off just the last portion of the url.

For example, if the room link is `https://www.sococo.com/web/join/abunchfocharactersgohere`, the room code you would use is `abunchfocharactersgohere`

### Heroku

    % heroku config:add HUBOT_SOCOCO_SERVER="https://as-vip.sococo.net"
    % heroku config:add HUBOT_SOCOCO_TOKEN="MY_SOCOCO_API_TOKEN"
    % heroku config:add HUBOT_SOCOCO_ROOMCODE="MY_GUEST_ACCESS_URL_ID"

### OSX/Linux

    % export HUBOT_SOCOCO_SERVER="https://as-vip.sococo.net"
    % export HUBOT_SOCOCO_TOKEN="MY_SOCOCO_API_TOKEN"
    % export HUBOT_SOCOCO_ROOMCODE="MY_GUEST_ACCESS_URL_ID"

### Windows

From Powershell (may require run as administrator):

    setx HUBOT_SOCOCO_SERVER "https://as-vip.sococo.net" /m
    setx HUBOT_SOCOCO_TOKEN "MY_SOCOCO_API_TOKEN" /m
    setx HUBOT_SOCOCO_ROOMCODE "MY_GUEST_ACCESS_URL_ID" /m
    
## Running The Bot

    bin/hubot -a sococo --name myhubot
