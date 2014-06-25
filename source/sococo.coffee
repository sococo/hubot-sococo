{Adapter,TextMessage} = require 'hubot'
Faye = require 'faye'
http = require 'http'

class SococoMessage
  constructor:(@text) -> @
  toJSON: () -> {
    "messageType": "Message",
    "contentData": @text
  }

class Sococo extends Adapter
  emote: (envelope, strings...) ->
    @send envelope, "* #{str}" for str in strings

  reply: (envelope, strings...) ->
    console.log("reply to user")
    strings = strings.map (s) -> "#{envelope.user.name}: #{s}"
    @send envelope, strings...

  send: (envelope, strings...) ->
    #console.log "Send msg on channel: #{@options.channel}"
    return if not @client
    @client.publish @options.channel, new SococoMessage(str).toJSON() for str in strings
    @

  close: ->
    console.log "Shutting down bot"
    return if not @client
    @client.publish
      messageType:"Exit",
      reason:"BOT_SHUTDOWN"

  run: ->
    @seen = {}
    @options =
      server:   process.env.HUBOT_SOCOCO_SERVER or null
      token:    process.env.HUBOT_SOCOCO_TOKEN or null
      # TODO: Remove when api params aren't needed.
      room:     process.env.HUBOT_SOCOCO_ROOM or "1344FD08-23C9-4BA6-83AE-A33A0E08A333"
      space:    process.env.HUBOT_SOCOCO_SPACE or "cb5a892a-f794-4495-a5b9-46c2013c6889"
      channel:  "/API"

    if not @options.server or not @options.token
      @robot.logger.error("HUBOT_SOCOCO_SERVER and HUBOT_SOCOCO_TOKEN env variables must be set")
      return process.exit 1

    process.on 'uncaughtException', (err) =>
      @robot.logger.error err.stack

    console.log "Sococo init"

    apiParams = "token=#{@options.token}&zoneId=#{@options.room}&appId=#{@options.space}"
    @client = new Faye.Client(@options.server)
    @client.setHeader('API-Cookie', encodeURI(apiParams))
    console.log("Connecting to Bayeux server: #{@options.server} with params #{apiParams}")
    @client.connect () =>

      identified = false
      console.log("Connected #{@robot.name} to : #{@options.server}")

      identifyMsg = "____IDENTIFY_BOT___)"
      botSuid = null

      # Subscribe to the API channel
      sub = @client.subscribe @options.channel, (msg) =>
        msg = JSON.parse msg if typeof msg == "string"
        if msg.messageType == "Message"
          # TODO: Remove this.  Check for special msg to extract our SUID from.  Server will send this with auth REST call.
          #console.log JSON.stringify msg, null, 3
          if not identified
            return if msg.contentData isnt identifyMsg or typeof msg.senderID is 'undefined'
            identified = true
            botSuid = msg.senderID
            console.log "Found bot #{botSuid}"
            @emit 'connected'
            return

          # Filter out messages sent by the bot
          if botSuid == msg.senderID
            #console.log "Filter out bot msg #{msg.contentData}"
            return

          # TODO: Remove this.  Filter out duplicates manually, server should stop sending them.
          msgKey = '' + msg.senderID + msg.timestamp
          return if @seen.hasOwnProperty msgKey
          @seen[msgKey] = true

          console.log "<-- #{msg.contentData}"
          user = @robot.brain.userForId msg.senderID, name: msg.senderDisplayName, room: "TheRoom"
          textMessage = new TextMessage user, msg.contentData, msgKey
          @receive textMessage
        else
          console.log(msg)

      sub.callback () =>
        console.log("subscribed on",@options.channel)

        # TODO: Replace this with the commented out 'connected' emit below.  once the need for identifyMsg is over.
        @client.publish @options.channel, new SococoMessage(identifyMsg).toJSON()
        #@emit 'connected'


      sub.errback (err) => @robot.logger.error err.stack or err


exports.use = (robot) ->
  new Sococo robot
