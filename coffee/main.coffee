class Main
  constructor:  ->
    @init()
    @initCSS()
    @initScroll()
    @initMessage()
    @initSocket()

  init: ->
    @started = false
    @finished = false
    @team = null
    @team = null
    @scrollValue = 0
    @prevScrollValue = 0
    @room_id = null
    @setTeam "a"

  initCSS: ->
    height = Number $('#background .border').css('height').replace('px', '')
    top = $(window).height() * 0.5 - height / 2
    $('#background .border').css 'top', top

  initScroll: ->
    @scrollManager = new ScrollManager()
    @scrollManager.scrollHandelr = (top, prev) =>
      height = $('#scroll_body').height()
      start_height = height * 0.9
      @scrollValue += -(top - prev)
      if top < height / 2
        $('#scroll_container').scrollTop(start_height)
        prev = start_height
      else
        prev = top
      return prev

  initMessage: ->
    @message = new MessageManager
    @message.show '.connecting'

  initSocket: ->
    socket.onopen = =>
      @sendLocation()
    socket.onmessage = (data) =>
      console.log data
      switch data.event
        when 'location'
          @setRoom data.room_id
        when 'scroll'
          @receiveScroll data

  setRoom: (room_id) ->
    @room_id = room_id
    $('#message_rope_id').text("綱ID: #{room_id}")
    @message.show '.team_select'
    # @gameStart()

  setTeam: (team) ->
    @team = team
    if team == 'a'
      $('#background .friend').css 'background-color', 'red'
      $('#background .enemy').css 'background-color', 'white'
    else
      $('#background .friend').css 'background-color', 'white'
      $('#background .enemy').css 'background-color', 'red'

  sendLocation: ->
    successCallback = (position) ->
      location =
        latitude: position.coords.latitude
        longitude: position.coords.longitude
      socket.send
        event: "location"
        location: location
    errorCallback = ->
      alert("位置情報の取得に失敗しました")
    navigator.geolocation.getCurrentPosition successCallback, errorCallback

  # ---- send data
  sendScroll: ->
    socket.send
      event: "scroll"
      room_id: @room_id
      team: @team
      value: @scrollValue - @prevScrollValue
    @prevScrollValue = @scrollValue

  receiveScroll: (data) ->
    if @team == 'a'
      friend = data.value.a
      enemy = data.value.b
    if @team == 'b'
      friend = data.value.b
      enemy = data.value.a
    return if friend + enemy == 0
    height = Number $('#background .border').css('height').replace('px', '')
    top = $(window).height() * (0.5 + (friend - enemy) / 100000) - height / 2
    $('#background .border').animate
      "top": top

  # ---- game start
  gameStartAnimation: (completion) ->
    setTimeout ->
      $('#start_button').hide()
      $('#three_button').show()
    , 1000
    setTimeout ->
      $('#three_button').hide()
      $('#two_button').show()
    , 2000
    setTimeout ->
      $('#two_button').hide()
      $('#one_button').show()
    , 3000
    setTimeout ->
      $('#one_button').hide()
      $('#go_button').show()
    , 4000
    setTimeout ->
      $('#go_button').hide()
      socket.send('start')
    , 4500
    setTimeout completion, 4500

  gameStart: ->
    @started = true
    interval = 0.5
    _loop = =>
      @sendScroll()
      if @started and not @finished
        setTimeout _loop, interval * 1000
    _loop()

class ScrollManager
  constructor: ->
    @initTouchEvent()
    @initScrollEvent()
    _loop = =>
      @update()
      setTimeout _loop, 33
    _loop()

  initTouchEvent: ->
    self = @
    @touchPos =
      x: 0, y: 0
    @prevPos =
      x: 0, y: 0
    @prevScrollPos = 0
    @speed =
      x: 0, y: 0
    @touching = false
    getPos = (e) ->
      if e.type == 'touchstart' or e.type == 'touchmove'
        x: e.originalEvent.changedTouches[0].pageX
        y: e.originalEvent.changedTouches[0].pageY
      else
        x: e.pageX
        y: e.pageY
    $('#scroll_container').on
      'touchstart mousedown': (e) ->
        e.preventDefault()
        eventPos = getPos e
        @initialTouchPos = eventPos
        @initialDocPos = $(this).position()
        self.touching = true
        self.touchPos = eventPos
        self.prevPos = eventPos
      'touchmove mousemove': (e) ->
        return if !self.touching
        e.preventDefault()
        eventPos = getPos e
        self.touchPos = eventPos
      'touchend mouseup': (e) ->
        return if !self.touching
        self.touching = false
        delete @initialTouchPos
        delete @initialDocPos

  initScrollEvent: ->
    height = $('#scroll_body').height()
    start_height = height * 0.9
    @prevScrollPos = start_height
    $('#scroll_container').scrollTop(start_height)
    $('#scroll_container').scroll (e) =>
      e.preventDefault()
      top = $('#scroll_container').scrollTop()
      if @scrollHandelr
        @prevScrollPos = @scrollHandelr(top, @prevScrollPos)
  update: ->
    if @touching
      @speed.y = - (@touchPos.y - @prevPos.y)
    top = $('#scroll_container').scrollTop() + @speed.y
    $('#scroll_container').scrollTop(top)
    if @scrollHandelr
      @prevScrollPos = @scrollHandelr(top, @prevScrollPos)
    @prevPos = @touchPos
    friction = 5
    next_speed = Math.abs(@speed.y) - friction
    if next_speed < 0
      next_speed = 0
    @speed.y = next_speed * Math.sign(@speed.y)


class MessageManager
  constructor: ->
    @hideAll()
  show: (selector) ->
    @hideAll()
    $("#message_container " + selector).each ->
      $(@).css 'display', 'block'
  hideAll: ->
    $('#message_container .message').each ->
      $(@).css 'display', 'none'

# ---
# generated by js2coffee 2.1.0

$ ->
  app = new Main()
  # $('#red_button').click ->
  #   app.repeat()
  #   socket.send(team: 'white')
  # $('#white_button').click ->
  #   app.repeat()
  #   socket.send(team: 'red')
  # $('#start_button').click ->
  #   app.gameStart()
  #   socket.send('start')

