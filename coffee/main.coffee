class Main
  constructor:  ->
    @init()
    @initCSS()
    @initScroll()
    @initSocket()
    @sendLocation()

  init: ->
    @started = false
    @finished = false
    @team = null
    @scrollValue = 0
    @room_id = null

  initCSS: ->
    $('#team_select').css('margin-left', $(window).width()/2-225).css('margin-top', $(window).height()/2-250)
    $('#red_button').css('margin-left', $(window).width()/2-200).css('margin-top', $(window).height()/2-50)
    $('#white_button').css('margin-left', $(window).width()/2).css('margin-top', $(window).height()/2-50)
    $('#start_button').css('margin-left', $(window).width()/2-150).css('margin-top', $(window).height()/2-100)
    $('#one_button').css('margin-left', $(window).width()/2-71.5).css('margin-top', $(window).height()/2-100)
    $('#two_button').css('margin-left', $(window).width()/2-71.5).css('margin-top', $(window).height()/2-100)
    $('#three_button').css('margin-left', $(window).width()/2-71.5).css('margin-top', $(window).height()/2-100)
    $('#go_button').css('margin-left', $(window).width()/2-107).css('margin-top', $(window).height()/2-100)

  initScroll: ->
    height = $('#scroll_body').height()
    start_height = height * 0.9
    prev = start_height
    $('#scroll_container').scrollTop(start_height)
    $('#scroll_container').scroll =>
      top = $('#scroll_container').scrollTop()
      @scrollValue += -(top - prev)
      if top < height / 2
        $('#scroll_container').scrollTop(start_height)
        prev = start_height
      else
        prev = top

  initSocket: ->
    socket.onmessage = (data) =>
      console.log data
      switch data.event
        when 'location'
          @setRoom data.room_id

  setRoom: (room_id) ->
    @room_id = room_id

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
      event: scroll
      team: @team
      value: @scrollValue

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

$ ->
  app = new Main()
  $('#red_button').click ->
    app.repeat()
    socket.send(team: 'white')
  $('#white_button').click ->
    app.repeat()
    socket.send(team: 'red')
  $('#start_button').click ->
    app.gameStart()
    socket.send('start')

