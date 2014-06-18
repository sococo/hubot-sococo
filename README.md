# Hubot Sococo Adapter

A Hubot adapter to connect bots to the Sococo chat service.

## Installation and Setup

To get your own hubot up and running we recommend following the [Getting Started](https://github.com/github/hubot/tree/master/docs) directions from the hubot wiki, they are summarized here:

    % npm install -g hubot coffee-script
    % hubot --create myhubot
    % cd myhubot
    % npm install hubot-sococo --save && npm install
    % HUBOT_SOCOCO_SERVER=api.sococo.com \
      HUBOT_SOCOCO_TOKEN="MY_API_TOKEN" \
      bin/hubot -a sococo --name myhubot

**Note**: The default hubot configuration will use a redis based brain that assumes the redis server is already running.  Either start your local redis server (usually with `redis-start &`) or remove the `redis-brain.coffee` script from the default `hubot-scripts.json` file.

## Configuring the Adapter

The Sococo adapter requires only the following environment variables.

* `HUBOT_SOCOCO_SERVER`
* `HUBOT_SOCOCO_TOKEN`

### Sococo Server

This is the full hostname or IP address of the Sococo chat server you want your hubot
to connect to. Make a note of it.

### Sococo Token

This is the token generated for your bot from the Sococo website.

### Configuring the variables on Heroku

    % heroku config:add HUBOT_SOCOCO_SERVER="..."

    % heroku config:add HUBOT_SOCOCO_TOKEN="MY_SOCOCO_API_TOKEN"

### Configuring the variables on UNIX

    % export HUBOT_SOCOCO_SERVER="..."

    % export HUBOT_SOCOCO_TOKEN="MY_SOCOCO_API_TOKEN"

### Configuring the variables on Windows

From Powershell:

    setx HUBOT_SOCOCO_SERVER "..." /m

    setx HUBOT_SOCOCO_TOKEN "MY_SOCOCO_API_TOKEN" /m
    
