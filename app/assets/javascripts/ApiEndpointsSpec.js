describe("Tic-Tac-Toe Game", function(){

  let defaultContent = {};
  beforeEach(function(){
    defaultContent = {
      token: "gIkuvaNzQIHg97ATvDxqgjtO",
      team_id: "T0001",
      team_domain: "example",
      channel_id: "C2147483705",
      channel_name: "test",
      user_id: "U2147483697",
      user_name: "",
      command: "",
      text: "",
      response_url: "https://hooks.slack.com/commands/1234/5678"
    };
    successResponseKeeper(false);
    errorResponseKeeper(false);
  });


  // it("should make a real AJAX request", function () {
  //   var callback = jasmine.createSpy();
  //   makeAjaxCall(callback);
  //   waitsFor(function() {
  //       return callback.callCount > 0;
  //   }, "The Ajax call timed out.", 5000);
  //
  //   runs(function() {
  //       expect(callback).toHaveBeenCalled();
  //   });

  describe("/challenge [opponent's username]", function(){
    afterEach(function(){
      defaultContent.command = "/destroy_all"
      makeAjaxCall(defaultContent, ignore, ignore);
    });

    describe("starts the game with opponent's username as parameter, and asks the opponent's consent", function(){
      beforeEach(function(done){
        defaultContent.user_name = "Steve";
        defaultContent.command = "/challenge";
        defaultContent.text = "Silly";
        makeAjaxCall(defaultContent, successResponseKeeper, errorResponseKeeper, done);
      });
      it("spec", function(done){
        expect(successResponseKeeper().text).toMatch("Steve challenges Silly");
        done();
      });
    });

    describe("if the challenged player accepts the game, it returns the empty gameboard", function(){
      beforeEach(function(done){
        defaultContent.user_name = "Steve";
        defaultContent.command = "/challenge";
        defaultContent.text = "Silly";
        makeAjaxCall(defaultContent, function(){
          let acceptContent = Object.assign({}, defaultContent);
          acceptContent.command = "/accept";
          acceptContent.user_name = "Silly";
          makeAjaxCall(acceptContent, successResponseKeeper, errorResponseKeeper, done);
        });

      });
      it("spec", function(done){
        expect(successResponseKeeper().text).toMatch("This is a new game! It's Silly's turn(X)");
        done();
      });
    });

    // describe("the challenge expires in 1 minutes");

    describe("allows only one challenge per channel at a time", function(){
      beforeEach(function(done){
        defaultContent.user_name = "Steve";
        defaultContent.command = "/challenge";
        defaultContent.text = "Silly";
        makeAjaxCall(defaultContent, secondCall, log);

        function secondCall(){
          let secondContent = Object.assign({}, defaultContent)
          secondContent.user_name = "Jesse";
          secondContent.command = "/challenge";
          secondContent.text = "Mateo";
          makeAjaxCall(secondContent, log, errorResponseKeeper, done);
        };
      });

      it("spec", function(done){
        expect(errorResponseKeeper().text).toMatch("You cannot start a new game while there is a pending challenge");
        done();
      });
    });

    describe("returns error msg if the opponent's username is missing", function(){
      beforeEach(function(done){
        defaultContent.user_name = "Steve";
        defaultContent.command = "/challenge";
        makeAjaxCall(defaultContent, log, errorResponseKeeper, done);
      });

      it("spec", function(done){
        expect(errorResponseKeeper().text).toMatch("You need to challenge another player");
        done();
      });
    });

    describe("returns error msg if a game is alreayd taking place in the channel", function(){
      beforeEach(function(done){
        defaultContent.user_name = "Steve";
        defaultContent.command = "/challenge";
        defaultContent.text = "Silly";
        makeAjaxCall(defaultContent, secondCall, log);

        function secondCall(){
          let acceptContent = Object.assign({}, defaultContent);
          acceptContent.command = "/accept";
          acceptContent.user_name = "Silly";
          makeAjaxCall(acceptContent, thirdCall, log);
        };

        function thirdCall(){
          let thirdContent = Object.assign({}, defaultContent);
          thirdContent.user_name = "Hiro";
          thirdContent.command = "/challenge";
          thirdContent.text = "Dan";
          makeAjaxCall(thirdContent, log, errorResponseKeeper, done);
        };
      });
      it("spec", function(done){
        expect(errorResponseKeeper().text).toMatch("You need to challenge another player");
        done();
      });
    });

    describe("handles multiple games taking place in different channels", function(){
      beforeEach(function(done){
        defaultContent.user_name = "Steve";
        defaultContent.command = "/challenge";
        defaultContent.text = "Silly";
        makeAjaxCall(defaultContent, secondCall, log);

        function secondCall(){
          let acceptContent = Object.assign({}, defaultContent);
          acceptContent.command = "/accept";
          acceptContent.user_name = "Silly";
          makeAjaxCall(acceptContent, thirdCall, log);
        };

        function thirdCall(){
          let thirdContent = Object.assign({}, defaultContent);
          thirdContent.user_name = "Hiro";
          thirdContent.command = "/challenge";
          thirdContent.text = "Dan";
          thirdContent.channel_id = "12345";
          makeAjaxCall(thirdContent, forthCall, log);
        };

        function fourthCall(){
          let fourthContent = Object.assign({}, defaultContent);
          fourthContent.user_name = "Dan";
          fourthContent.command = "/accept";
          fourthContent.channel_id = "12345";
          makeAjaxCall(fourthContent, successResponseKeeper, errorResponseKeeper, done);
        }
      });
      it("spec", function(done){
        expect(errorResponseKeeper().text).toMatch("You need to challenge another player");
        done();
      });
    });
    // API
    it("returns error msg if the opponent is not logged in");
  });

  describe("/accept", function(){
    it("when there is no challanges, it returns error msg");

    // Buttons
    it("lets users responde with buttons");
  });

  describe("/decline", function(){
    it("returns the confirmation");
    it("when there is no challanges, it returns error msg");
  });

  describe("/mark [position]", function(){
    it("takes the position and returns the updated board");
    it("returns error msg to the moves not by the wrong player");
    it("returns error msg to the moves by audience");
    it("returns error msg if the place has been marked already");
    it("if the move was the winning move, returns the result");
    it("if the move makes the game tie, it returns the result");
    it("if the game is over, it it returns error msg");
    it("when there is no game in progress, it it returns error msg");
  });

  describe("/show_board", function(){
    it("returns the board of the game in progress");
    it("if no game is in progress, it returns the most recent game board and results");
  });

  // describe("/record", function(){
  //   it("provides the recent games of the channel");
  // });

  describe("/abandon", function(){
    it("Either of the players can abandon the game");
    it("returns error message if you are not a player");
    it("can be used to cancel challenge");

    // Buttons
    it("lets users choose yes/no with buttons");
    it("Asks for confirmation before abandonment");
    // API & Event Listener
    it("when the player logs out the game is automatically abandoned");
  });



  function makeAjaxCall(content, successCallback, errorCallback, done = undefined){
    let request = new XMLHttpRequest();
    request.open("POST", `http://localhost:3000/api/games${content.command}`, true);
    request.onload = function(resp){
      if (request.status === 200){
        successCallback(JSON.parse(request.responseText));
        if (done) { done(); }
      } else {
        errorCallback(JSON.parse(resp));
        if (done) { done(); }
      }
    }
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.send(parseContent(content))
  };

  function parseContent(content){
    let formatted = "";
    for(let propName in content){
      formatted += propName + "=" +
                   content[propName] + "&";
    }
    return formatted.slice(0,formatted.length-1);
  }

  function successResponseKeeper(_resp_s = undefined){
    // if (_resp_s) { debugger; }
    if (_resp_s !== undefined){
      this._resp_s = _resp_s;
    } else {
      return this._resp_s;
    }
  }
  function errorResponseKeeper(_resp_e = undefined){
    // if (_resp_e) { debugger; }
    if (_resp_e !== undefined){
      this._resp_e = _resp_e;
    } else {
      return this._resp_e;
    }
  }

  function log(res){
    console.log(res);
  }

  function ignore(){
  }

});
