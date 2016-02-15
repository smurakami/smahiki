// Generated by CoffeeScript 1.9.2
(function() {
  var Main, MessageManager, ScrollManager;

  Main = (function() {
    function Main() {
      this.init();
      this.initCSS();
      this.initScroll();
      this.initMessage();
      this.initTeamSelect();
      this.initSocket();
    }

    Main.prototype.init = function() {
      this.started = false;
      this.able_to_start = false;
      this.team_num = false;
      this.finished = false;
      this.team = null;
      this.team = null;
      this.scrollValue = 0;
      this.prevScrollValue = 0;
      this.room_id = null;
      return this.finish_scroll_val = 1000;
    };

    Main.prototype.initCSS = function() {
      var height, top;
      height = Number($('#background .border').css('height').replace('px', ''));
      top = $(window).height() * 0.5 - height / 2;
      return $('#background .border').css('top', top);
    };

    Main.prototype.initScroll = function() {
      this.scrollManager = new ScrollManager();
      return this.scrollManager.scrollHandler = (function(_this) {
        return function(top, prev) {
          var height, max_top, min_top, start_height;
          height = $('#scroll_body').height();
          min_top = height * 0.1;
          max_top = height * 0.9;
          start_height = height * 0.5;
          _this.scrollValue += -(top - prev);
          if (top < min_top || top > max_top) {
            $('#scroll_container').scrollTop(start_height);
            prev = start_height;
          } else {
            prev = top;
          }
          return prev;
        };
      })(this);
    };

    Main.prototype.initMessage = function() {
      this.message = new MessageManager;
      return this.message.show('.connecting');
    };

    Main.prototype.initTeamSelect = function() {
      $('#message_container .team_select .red_button').click((function(_this) {
        return function() {
          return _this.setTeam("a");
        };
      })(this));
      $('#message_container .team_select .white_button').click((function(_this) {
        return function() {
          return _this.setTeam("b");
        };
      })(this));
      return $('#message_container .team_select .start_button').click((function(_this) {
        return function() {
          if (_this.able_to_start) {
            return socket.send({
              event: 'start'
            });
          }
        };
      })(this));
    };

    Main.prototype.initSocket = function() {
      socket.onopen = (function(_this) {
        return function() {
          return _this.sendLocation();
        };
      })(this);
      return socket.onmessage = (function(_this) {
        return function(data) {
          console.log(data);
          return _this.onmessage(data);
        };
      })(this);
    };

    Main.prototype.onmessage = function(data) {
      switch (data.event) {
        case 'location':
          return this.setRoom(data.room_id);
        case 'team':
          return this.setTeamNum(data);
        case 'start':
          return this.gameStart();
        case 'scroll':
          return this.receiveScroll(data);
        case 'finish':
          return this.finish(data);
      }
    };

    Main.prototype.setRoom = function(room_id) {
      this.room_id = room_id;
      $('#message_rope_id').text("綱ID: " + room_id);
      return this.message.show('.team_select');
    };

    Main.prototype.setTeam = function(team) {
      this.team = team;
      if (team === 'a') {
        $('#message_container .team_select .red_button').removeClass('disabled');
        $('#message_container .team_select .white_button').addClass('disabled');
        $('#background .friend').css('background-color', 'red');
        $('#background .enemy').css('background-color', 'white');
      } else if (team === 'b') {
        $('#message_container .team_select .red_button').addClass('disabled');
        $('#message_container .team_select .white_button').removeClass('disabled');
        $('#background .friend').css('background-color', 'white');
        $('#background .enemy').css('background-color', 'red');
      } else {
        console.log('invalid team name');
        return;
      }
      return socket.send({
        event: 'team',
        team: team
      });
    };

    Main.prototype.setTeamNum = function(data) {
      this.able_to_start = data.able_to_start;
      this.team_num = data.team_num;
      if (this.able_to_start) {
        $('#message_container .team_select .start_button').removeClass('disabled');
      } else {
        $('#message_container .team_select .start_button').addClass('disabled');
      }
      $('#message_container .team_select .red_team_number').text(this.team_num.a + "人");
      return $('#message_container .team_select .white_team_number').text(this.team_num.b + "人");
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
      socket.send({
        event: "scroll",
        room_id: this.room_id,
        team: this.team,
        value: this.scrollValue - this.prevScrollValue
      });
      return this.prevScrollValue = this.scrollValue;
    };

    Main.prototype.receiveScroll = function(data) {
      var enemy, friend, height, top;
      this.finish_scroll_val = data.finish_scroll_val;
      if (this.team === 'a') {
        friend = data.value.a;
        enemy = data.value.b;
      }
      if (this.team === 'b') {
        friend = data.value.b;
        enemy = data.value.a;
      }
      if (friend + enemy === 0) {
        return;
      }
      height = Number($('#background .border').css('height').replace('px', ''));
      top = $(window).height() * (0.5 + 0.5 * (friend - enemy) / this.finish_scroll_val) - height / 2;
      console.log(friend - enemy);
      return $('#background .border').animate({
        "top": top
      });
    };

    Main.prototype.gameStartAnimation = function(completion) {
      var interval;
      interval = 666;
      setTimeout((function(_this) {
        return function() {
          return _this.message.show('.count_three');
        };
      })(this), interval * 0);
      setTimeout((function(_this) {
        return function() {
          return _this.message.show('.count_two');
        };
      })(this), interval * 1);
      setTimeout((function(_this) {
        return function() {
          return _this.message.show('.count_one');
        };
      })(this), interval * 2);
      setTimeout((function(_this) {
        return function() {
          return _this.message.show('.count_go');
        };
      })(this), interval * 3);
      return setTimeout((function(_this) {
        return function() {
          _this.message.hideAll();
          return completion();
        };
      })(this), interval * 4);
    };

    Main.prototype.gameStart = function() {
      return this.gameStartAnimation((function(_this) {
        return function() {
          var _loop, interval;
          _this.message.hideMessageContainer();
          _this.started = true;
          interval = 0.5;
          _loop = function() {
            _this.sendScroll();
            if (_this.started && !_this.finished) {
              return setTimeout(_loop, interval * 1000);
            }
          };
          return _loop();
        };
      })(this));
    };

    Main.prototype.finish = function(data) {
      return setTimeout((function(_this) {
        return function() {
          var winner;
          winner = data.winner;
          _this.finished = true;
          if (winner === 'a') {
            $("#message_container .finish .red").css('display', 'block');
            $("#message_container .finish .white").css('display', 'none');
          } else if (winner === 'b') {
            $("#message_container .finish .red").css('display', 'none');
            $("#message_container .finish .white").css('display', 'block');
          } else {
            console.log('invalid winner');
            return;
          }
          if (winner === _this.team) {
            $("#message_container .finish .win").css('display', 'block');
            $("#message_container .finish .lose").css('display', 'none');
          } else {
            $("#message_container .finish .win").css('display', 'none');
            $("#message_container .finish .lose").css('display', 'block');
          }
          _this.message.showMessageContainer();
          return _this.message.show('.finish');
        };
      })(this), 300);
    };

    return Main;

  })();

  ScrollManager = (function() {
    function ScrollManager() {
      var _loop;
      this.initTouchEvent();
      this.initScrollEvent();
      _loop = (function(_this) {
        return function() {
          _this.update();
          return setTimeout(_loop, 33);
        };
      })(this);
      _loop();
    }

    ScrollManager.prototype.initTouchEvent = function() {
      var getPos, self;
      self = this;
      this.touchPos = {
        x: 0,
        y: 0
      };
      this.prevPos = {
        x: 0,
        y: 0
      };
      this.prevScrollPos = 0;
      this.speed = {
        x: 0,
        y: 0
      };
      this.touching = false;
      getPos = function(e) {
        if (e.type === 'touchstart' || e.type === 'touchmove') {
          return {
            x: e.originalEvent.changedTouches[0].pageX,
            y: e.originalEvent.changedTouches[0].pageY
          };
        } else {
          return {
            x: e.pageX,
            y: e.pageY
          };
        }
      };
      return $('#scroll_container').on({
        'touchstart mousedown': function(e) {
          var eventPos;
          e.preventDefault();
          eventPos = getPos(e);
          this.initialTouchPos = eventPos;
          this.initialDocPos = $(this).position();
          self.touching = true;
          self.touchPos = eventPos;
          return self.prevPos = eventPos;
        },
        'touchmove mousemove': function(e) {
          var eventPos;
          if (!self.touching) {
            return;
          }
          e.preventDefault();
          eventPos = getPos(e);
          return self.touchPos = eventPos;
        },
        'touchend mouseup': function(e) {
          if (!self.touching) {
            return;
          }
          self.touching = false;
          delete this.initialTouchPos;
          return delete this.initialDocPos;
        }
      });
    };

    ScrollManager.prototype.initScrollEvent = function() {
      var height, start_height;
      height = $('#scroll_body').height();
      start_height = height * 0.5;
      this.prevScrollPos = start_height;
      $('#scroll_container').scrollTop(start_height);
      return $('#scroll_container').scroll((function(_this) {
        return function(e) {
          var top;
          e.preventDefault();
          top = $('#scroll_container').scrollTop();
          if (_this.scrollHandler) {
            return _this.prevScrollPos = _this.scrollHandler(top, _this.prevScrollPos);
          }
        };
      })(this));
    };

    ScrollManager.prototype.update = function() {
      var friction, next_speed, top;
      if (this.touching) {
        this.speed.y = -(this.touchPos.y - this.prevPos.y);
      }
      top = $('#scroll_container').scrollTop() + this.speed.y;
      $('#scroll_container').scrollTop(top);
      if (this.scrollHandler) {
        this.prevScrollPos = this.scrollHandler(top, this.prevScrollPos);
      }
      this.prevPos = this.touchPos;
      friction = 5;
      next_speed = Math.abs(this.speed.y) - friction;
      if (next_speed < 0) {
        next_speed = 0;
      }
      return this.speed.y = next_speed * Math.sign(this.speed.y);
    };

    return ScrollManager;

  })();

  MessageManager = (function() {
    function MessageManager() {
      this.hideAll();
    }

    MessageManager.prototype.show = function(selector) {
      this.hideAll();
      return $("#message_container " + selector).each(function() {
        return $(this).css('display', 'block');
      });
    };

    MessageManager.prototype.hideAll = function() {
      return $('#message_container .message').each(function() {
        return $(this).css('display', 'none');
      });
    };

    MessageManager.prototype.hideMessageContainer = function() {
      return $('#message_container').css('display', 'none');
    };

    MessageManager.prototype.showMessageContainer = function() {
      return $('#message_container').css('display', 'block');
    };

    return MessageManager;

  })();

  $(function() {
    var app;
    return app = new Main();
  });

}).call(this);
