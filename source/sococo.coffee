{Adapter,TextMessage} = require 'hubot'
Faye = require 'faye'
http = require 'http'

class SococoMessage
  constructor:(@text) -> @
  toJSON: () -> {
    "messageType": "Message",
    "contentData": this.text
  }

class Sococo extends Adapter
  emote: (envelope, strings...) ->
    @send envelope, "* #{str}" for str in strings

  reply: (envelope, strings...) ->
    console.log("reply to user")
    strings = strings.map (s) -> "#{envelope.user.name}: #{s}"
    @send envelope, strings...

  send: (envelope, strings...) ->
    console.log "Send msg on channel: #{@channel}"
    return if not @client
    @client.publish @channel, new SococoMessage(str).toJSON() for str in strings
    @

  close: ->
    console.log "Shutting down bot"
    return if not @client
    @client.publish
      messageType:"Exit",
      reason:"BOT_SHUTDOWN"

  run: ->
    process.on 'uncaughtException', (err) =>
      @robot.logger.error err.stack

    console.log "Sococo init"

    # TODO: get this info from REST call to auth.
    @server = 'http://asdeveug01.eug.sococo.net:8080/straw/straw';
    @channel = zoneChannel = "/API"

    # TODO: environment variables
    sococoToken = "7fd3fa31-68e3-4763-aaf1-1eb58970aff6"
    sococoRoom = "b52b2645-6b2d-447a-996f-e0c262369c70"
    sococoSpace = "a8ad572f-5aab-424d-a898-83fb7d9c0833"
    apiParams = "token=#{sococoToken}&zoneId=#{sococoRoom}&appId=#{sococoSpace}"

    @client = new Faye.Client(@server);
    @client.setHeader('API-Cookie', encodeURI(apiParams));

    @robot.logger.debug("Connecting to Bayeux server: #{@server}");

    @client.connect () =>

      console.log("Connected #{@robot.name} to : #{@server}");

      # Subscribe to the API channel
      sub = @client.subscribe zoneChannel, (msg) =>
        msg = JSON.parse msg if typeof msg == "string"
        if msg.messageType == "Message"
          console.log "pass msg to hubot: #{msg.contentData}"
          user = @robot.brain.userForId msg.senderID, name: msg.senderDisplayName, room: "TheRoom"
          textMessage = new TextMessage user, msg.contentData, "#{msg.senderID}#{msg.timestamp}"
          @receive textMessage
        else
          console.log(msg)

      sub.callback () =>
        @robot.logger.debug("subscribed on",zoneChannel);

        # Tell Hubot to load its scripts and initialize
        @emit "connected"


      sub.errback (err) => @robot.logger.error err.stack or err


exports.use = (robot) ->
  new Sococo robot
