class Main
  constructor:  ->
    @initCSS()
    @initSocket()
    @sendLocation()

  initCSS: ->
    $('#team_select').css('margin-left', $(window).width()/2-225).css('margin-top', $(window).height()/2-250)
    $('#red_button').css('margin-left', $(window).width()/2-200).css('margin-top', $(window).height()/2-50)
    $('#white_button').css('margin-left', $(window).width()/2).css('margin-top', $(window).height()/2-50)
    $('#start_button').css('margin-left', $(window).width()/2-150).css('margin-top', $(window).height()/2-100)
    $('#one_button').css('margin-left', $(window).width()/2-71.5).css('margin-top', $(window).height()/2-100)
    $('#two_button').css('margin-left', $(window).width()/2-71.5).css('margin-top', $(window).height()/2-100)
    $('#three_button').css('margin-left', $(window).width()/2-71.5).css('margin-top', $(window).height()/2-100)
    $('#go_button').css('margin-left', $(window).width()/2-107).css('margin-top', $(window).height()/2-100)

  initSocket: ->
    self = @
    socket.onmessage = (data) ->
      console.log data
      switch data.event
        when 'location'
          console.log ''
  sendLocation: ->
    successCallback = (position) ->
      location =
        latitude: position.coords.latitude
        longitude: position.coords.longitude
      socket.send
        event: "location"
        location: location
    errorCallback = ->
      alert("位置情報の取得に失敗したニャン")
    navigator.geolocation.getCurrentPosition successCallback, errorCallback

  repeat: ->
    $('body').css('background-image', 'url(../images/background.jpeg)')
    $('#red_button').hide()
    $('#white_button').hide()
    $('#team_select').hide()
    $('#start_button').show()
    $(window).scrollTop(90000)
    $(window).scroll ->
      if $(window).scrollTop() < 50000
        $(window).scrollTop(90000)

  gameStart: ->
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

