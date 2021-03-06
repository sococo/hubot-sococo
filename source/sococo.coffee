{Adapter,TextMessage} = require 'hubot'
Faye = require 'faye'
http = require 'http'
request = require 'request'
cookie = require 'cookie'
url = require 'url'

class SococoMessage
  constructor:(@text) -> @
  toJSON: () -> {
    "messageType": "Message",
    "contentData": @text,
    "senderType":"API"
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
    for str in strings
      msg = new SococoMessage(str).toJSON()
      @client.publish @options.channel, msg
      console.log "--> [#{@robot.name}] #{msg.contentData}"
    @

  close: ->
    console.log "Shutting down bot"
    return if not @client
    console.log "Disconnecting client"
    @client.disconnect()
    setTimeout ->
      process.exit(0)
    , 1000
  run: ->
    @options =
      server:   process.env.HUBOT_SOCOCO_SERVER or null
      token:    process.env.HUBOT_SOCOCO_TOKEN or null
      roomcode: process.env.HUBOT_SOCOCO_ROOMCODE or null
      # optional arguments that usually do not need to be changed:
      loginpath: process.env.HUBOT_SOCOCO_LOGINPATH or null
      bayeuxpath: process.env.HUBOT_SOCOCO_BAYEUXPATH or null
      fayedebug: process.env.HUBOT_SOCOCO_FAYEDEBUG or null
      encodecookies: process.env.HUBOT_SOCOCO_ENCODECOOKIES or false
      channel:  "/service/stream"

    if not @options.server or not @options.token
      @robot.logger.error("HUBOT_SOCOCO_SERVER and HUBOT_SOCOCO_TOKEN env variables must be set")
      return process.exit 1

    process.on 'uncaughtException', (err) =>
      @robot.logger.error err.stack

    console.log "Sococo init"

    loginPath = @options.loginpath or "/api/v1/login"

    # make a request to the /login endpoint to validate the api token and room code
    j = request.jar()
    reqOps =
      method: "post"
      url: "#{@options.server}#{loginPath}"
      json: true
      jar: j
      body:
        token: @options.token
        room: @options.roomcode

    console.log "Making login request to:", reqOps.url
    request reqOps, (error, response, body) =>
      if error || !response || response.statusCode != 200
        status = response && response.statusCode
        # TODO: should retry if code is 503 (60 seconds or whatever is in the response body)
        console.log "error connecting: ", status, error, body
        return

      # need to preserve cookies for the bayeux phase
      cookieString = j.getCookieString(reqOps.url)
      @connectStream cookieString

  connectStream: (cookieString) ->
    bayeuxPath = @options.bayeuxpath or "/api/v1/bayeux"
    streamUrl = "#{@options.server}#{bayeuxPath}"

    # must reparse the url into components so that we can set the cookies properly
    urlParts = url.parse streamUrl

    @client = new Faye.Client(streamUrl)

    if @options.fayedebug
      @client.addExtension
        incoming: (message, pipe) =>
          clientId = null
          console.log "FayIN [#{clientId}]: ", JSON.stringify(message)
          pipe message

      @client.addExtension
        outgoing: (message, pipe) =>
          clientId = null
          console.log "FayOUT[#{clientId}]: ", JSON.stringify(message)
          pipe message

    # faye doesn't support setting a cookie directly, so set the Cookie header
    cookies = cookie.parse cookieString
    for key,value of cookies
      if @options.encodecookies # this should normally be false, as these are pre-encoded
        value = encodeURIComponent(value)
        console.log "encoding cookie values",value

      cookieStr = "#{key}=#{value}; Path=#{urlParts.path}; Domain=#{urlParts.hostname}"
      console.log "Setting cookie: #{cookieStr}"
      @client.cookies.setCookie(cookieStr)

    console.log("Connecting to Bayeux server: #{streamUrl}")
    @client.connect () =>
      console.log("Connected #{@robot.name} to : #{@options.server}")

      # Subscribe to the API channel
      sub = @client.subscribe @options.channel, (msg) =>
        msg = JSON.parse msg if typeof msg == "string"
        if msg.messageType == "Message"
          # Filter out messages sent by the bot
          if msg.senderType == 'API' or typeof msg.senderType is 'undefined'
            #console.log "Filter out bot msg #{JSON.stringify(msg,null,3)}"
            return

          # Unique Key for each msg
          msgKey = '' + msg.senderID + msg.timestamp

          console.log "<-- [#{msg.senderType}] #{msg.contentData}"
          user = @robot.brain.userForId msg.senderID, name: msg.senderDisplayName, room: "TheRoom"
          textMessage = new TextMessage user, msg.contentData, msgKey
          @receive textMessage
        else
          console.log(msg)

      sub.callback () =>
        console.log("subscribed on",@options.channel)
        @emit 'connected'


      sub.errback (err) => @robot.logger.error err.stack or err


exports.use = (robot) ->
  new Sococo robot
