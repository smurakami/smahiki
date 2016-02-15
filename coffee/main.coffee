class Main
  constructor:  ->
    @init()
    @initCSS()
    @initScroll()
    @initMessage()
    @initTeamSelect()
    @initSocket() # 起点

  init: ->
    @started = false
    @train_mode = false
    @able_to_start = false
    @team_num = false
    @finished = false
    @team = null
    @team = null
    @scrollValue = 0
    @prevScrollValue = 0
    @room_id = null
    @finish_scroll_val = 1000 # 勝敗がつくスクロール量

  initCSS: ->
    height = Number $('#background .border').css('height').replace('px', '')
    top = $(window).height() * 0.5 - height / 2
    $('#background .border').css 'top', top

  initScroll: ->
    @scrollManager = new ScrollManager()
    @scrollManager.scrollHandler = (top, prev) =>
      height = $('#scroll_body').height()
      min_top = height * 0.1
      max_top = height * 0.9
      start_height = height * 0.5
      @scrollValue += -(top - prev)
      if top < min_top or top > max_top
        $('#scroll_container').scrollTop(start_height)
        prev = start_height
      else
        prev = top
      return prev

  initMessage: ->
    @message = new MessageManager
    @message.show '.connecting'

  initTeamSelect: ->
    $('#message_container .team_select .red_button').click =>
      @setTeam "a"
    $('#message_container .team_select .white_button').click =>
      @setTeam "b"
    $('#message_container .team_select .start_button').click =>
      if @able_to_start
        socket.send
          event: 'start'
    $('#message_container .team_select .train_button').click =>
      @startTrainMode()

  initSocket: ->
    socket.onopen = =>
      @sendLocation()
    socket.onmessage = (data) =>
      console.log data
      @onmessage data

  onmessage: (data) ->
    switch data.event
      when 'location'
        @setRoom data.room_id
      when 'team'
        @setTeamNum data
      when 'start'
        @gameStart()
      when 'scroll'
        @receiveScroll data
      when 'finish'
        @finish data

  setRoom: (room_id) ->
    @room_id = room_id
    $('#message_rope_id').text("綱ID: #{room_id}")
    @message.show '.team_select'

  setTeam: (team) ->
    @team = team
    if team == 'a'
      $('#message_container .team_select .red_button').removeClass 'disabled'
      $('#message_container .team_select .white_button').addClass 'disabled'
      $('#background .friend').css 'background-color', 'red'
      $('#background .enemy').css 'background-color', 'white'
    else if team == 'b'
      $('#message_container .team_select .red_button').addClass 'disabled'
      $('#message_container .team_select .white_button').removeClass 'disabled'
      $('#background .friend').css 'background-color', 'white'
      $('#background .enemy').css 'background-color', 'red'
    else
      console.log 'invalid team name'
      return
    socket.send
      event: 'team'
      team: team

  setTeamNum: (data) ->
    @able_to_start = data.able_to_start
    @team_num = data.team_num
    if @able_to_start
      $('#message_container .team_select .start_button').removeClass 'disabled'
    else
      $('#message_container .team_select .start_button').addClass 'disabled'
    $('#message_container .team_select .red_team_number').text "#{@team_num.a}人"
    $('#message_container .team_select .white_team_number').text "#{@team_num.b}人"

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
    @finish_scroll_val = data.finish_scroll_val
    if @team == 'a'
      friend = data.value.a
      enemy = data.value.b
    if @team == 'b'
      friend = data.value.b
      enemy = data.value.a
    return if friend + enemy == 0
    height = Number $('#background .border').css('height').replace('px', '')
    top = $(window).height() * (0.5 + 0.5 * (friend - enemy) / @finish_scroll_val) - height / 2
    console.log friend-enemy
    $('#background .border').animate
      "top": top

  # ---- game start
  gameStartAnimation: (completion) ->
    interval = 666
    setTimeout =>
      @message.show('.count_three')
    , interval * 0
    setTimeout =>
      @message.show('.count_two')
    , interval * 1
    setTimeout =>
      @message.show('.count_one')
    , interval * 2
    setTimeout =>
      @message.show('.count_go')
    , interval * 3
    setTimeout =>
      @message.hideAll()
      completion()
    , interval * 4

  gameStart: ->
    @gameStartAnimation =>
      @message.hideMessageContainer()
      @started = true
      interval = 0.5
      _loop = =>
        @sendScroll()
        if @started and not @finished
          setTimeout _loop, interval * 1000
      _loop()

  startTrainMode: ->
    @message.hideMessageContainer()
    @train = new TrainModeManager(@)

  finish: (data) ->
    setTimeout =>
      winner = data.winner
      @finished = true
      if winner == 'a'
        $("#message_container .finish .red").css 'display', 'block'
        $("#message_container .finish .white").css 'display', 'none'
      else if winner == 'b'
        $("#message_container .finish .red").css 'display', 'none'
        $("#message_container .finish .white").css 'display', 'block'
      else
        console.log 'invalid winner'
        return

      if winner == @team
        $("#message_container .finish .win").css 'display', 'block'
        $("#message_container .finish .lose").css 'display', 'none'
      else
        $("#message_container .finish .win").css 'display', 'none'
        $("#message_container .finish .lose").css 'display', 'block'

      @message.showMessageContainer()
      @message.show '.finish'
    , 300

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
    start_height = height * 0.5
    @prevScrollPos = start_height
    $('#scroll_container').scrollTop(start_height)
    $('#scroll_container').scroll (e) =>
      e.preventDefault()
      top = $('#scroll_container').scrollTop()
      if @scrollHandler
        @prevScrollPos = @scrollHandler(top, @prevScrollPos)
  update: ->
    if @touching
      @speed.y = - (@touchPos.y - @prevPos.y)
    top = $('#scroll_container').scrollTop() + @speed.y
    $('#scroll_container').scrollTop(top)
    if @scrollHandler
      @prevScrollPos = @scrollHandler(top, @prevScrollPos)
    @prevPos = @touchPos
    friction = 5
    next_speed = Math.abs(@speed.y) - friction
    if next_speed < 0
      next_speed = 0
    @speed.y = next_speed * Math.sign(@speed.y)


class TrainModeManager
  constructor: (app) ->
    @app = app
    $('#scroll_container #background .border').css 'display', 'none'
    $('#scroll_counter').css 'display', 'block'

    _loop = =>
      @update()
      setTimeout _loop, 33
    _loop()

  update: ->
    console.log
    console.log @app.scrollValue
    meter = @app.scrollValue / 667 * 0.104
    rounded = Math.floor(meter * 100) / 100
    $('#scroll_counter').text "#{rounded} m"


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
  hideMessageContainer: ->
    $('#message_container').css 'display', 'none'
  showMessageContainer: ->
    $('#message_container').css 'display', 'block'

$ ->
  app = new Main()

