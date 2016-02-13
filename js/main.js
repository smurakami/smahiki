// Generated by CoffeeScript 1.9.2
(function() {
  var Main;

  Main = (function() {
    function Main() {
      this.init();
      this.initCSS();
      this.initScroll();
      this.initSocket();
      this.sendLocation();
    }

    Main.prototype.init = function() {
      this.started = false;
      this.finished = false;
      this.team = null;
      this.scrollValue = 0;
      return this.room_id = null;
    };

    Main.prototype.initCSS = function() {
      $('#team_select').css('margin-left', $(window).width() / 2 - 225).css('margin-top', $(window).height() / 2 - 250);
      $('#red_button').css('margin-left', $(window).width() / 2 - 200).css('margin-top', $(window).height() / 2 - 50);
      $('#white_button').css('margin-left', $(window).width() / 2).css('margin-top', $(window).height() / 2 - 50);
      $('#start_button').css('margin-left', $(window).width() / 2 - 150).css('margin-top', $(window).height() / 2 - 100);
      $('#one_button').css('margin-left', $(window).width() / 2 - 71.5).css('margin-top', $(window).height() / 2 - 100);
      $('#two_button').css('margin-left', $(window).width() / 2 - 71.5).css('margin-top', $(window).height() / 2 - 100);
      $('#three_button').css('margin-left', $(window).width() / 2 - 71.5).css('margin-top', $(window).height() / 2 - 100);
      return $('#go_button').css('margin-left', $(window).width() / 2 - 107).css('margin-top', $(window).height() / 2 - 100);
    };

    Main.prototype.initScroll = function() {
      var height, prev, self, start_height;
      self = this;
      height = $('#scroll_body').height();
      start_height = height * 0.9;
      prev = start_height;
      $('#scroll_container').scrollTop(start_height);
      return $('#scroll_container').scroll(function() {
        var top;
        top = $('#scroll_container').scrollTop();
        self.scrollValue += -(top - prev);
        if (top < height / 2) {
          $('#scroll_container').scrollTop(start_height);
          return prev = start_height;
        } else {
          return prev = top;
        }
      });
    };

    Main.prototype.initSocket = function() {
      return socket.onmessage = function(data) {
        console.log(data);
        switch (data.event) {
          case 'location':
            return self.setRoom(data.room_id);
        }
      };
    };

    Main.prototype.setRoom = function(room_id) {
      return this.room_id = room_id;
    };

    Main.prototype.sendLocation = function() {
      var errorCallback, successCallback;
      successCallback = function(position) {
        var location;
        location = {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude
        };
        return socket.send({
          event: "location",
          location: location
        });
      };
      errorCallback = function() {
        return alert("位置情報の取得に失敗しました");
      };
      return navigator.geolocation.getCurrentPosition(successCallback, errorCallback);
    };

    Main.prototype.sendScroll = function() {
      return socket.send({
        event: scroll,
        team: this.team,
        value: this.scrollValue
      });
    };

    Main.prototype.gameStartAnimation = function(completion) {
      setTimeout(function() {
        $('#start_button').hide();
        return $('#three_button').show();
      }, 1000);
      setTimeout(function() {
        $('#three_button').hide();
        return $('#two_button').show();
      }, 2000);
      setTimeout(function() {
        $('#two_button').hide();
        return $('#one_button').show();
      }, 3000);
      setTimeout(function() {
        $('#one_button').hide();
        return $('#go_button').show();
      }, 4000);
      setTimeout(function() {
        $('#go_button').hide();
        return socket.send('start');
      }, 4500);
      return setTimeout(completion, 4500);
    };

    Main.prototype.gameStart = function() {
      return this.started = true;
    };

    return Main;

  })();

  $(function() {
    var app;
    app = new Main();
    $('#red_button').click(function() {
      app.repeat();
      return socket.send({
        team: 'white'
      });
    });
    $('#white_button').click(function() {
      app.repeat();
      return socket.send({
        team: 'red'
      });
    });
    return $('#start_button').click(function() {
      app.gameStart();
      return socket.send('start');
    });
  });

}).call(this);
