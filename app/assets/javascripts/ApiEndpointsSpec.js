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
      user_name: "Steve",
      command: "/weather",
      text: "94070",
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
    beforeEach(function(done){
      defaultContent.command = "/challenge";
      defaultContent.text = "Silly";
      makeAjaxCall(defaultContent, successResponseKeeper, errorResponseKeeper, done);
    });
    it("starts the game with opponent's username as parameter, and asks the opponent's consent", function(done){
      expect(successResponseKeeper().text).toMatch("Steve challenges Silly");
      done();
    });

    it("if the challenged player accepts the game, it returns the empty gameboard");
    it("the challenge expires in 1 minutes");
    it("allows only one challenge per channel at a time");

    it("returns error msg if the opponent's username is missing");
    it("returns error msg if a game is alreayd taking place in the channel");
    it("handles multiple games taking place in different channels");

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
    it("lets users choose yes/no with buttons")
    it("Asks for confirmation before abandonment");
    // API & Event Listener
    it("when the player logs out the game is automatically abandoned");
  });



  function makeAjaxCall(content, successCallback, errorCallback, done){
    let request = new XMLHttpRequest();
    request.open("POST", "http://localhost:3000/api/games" + content.command, true);
    request.onload = function(resp){
      if (request.status === 200){
        successCallback(JSON.parse(request.responseText))
        done();
      } else {
        errorCallback(JSON.parse(resp));
        done();
      }
    }
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.send(parseContent(content))
  };

  // function log(resp){
  //   console.log(resp);
  // }

  function parseContent(content){
    let formatted = "";
    for(let propName in content){
      formatted += propName + "=" +
                   content[propName] + "&";
    }
    return formatted.slice(0,formatted.length-1);
  }

  function successResponseKeeper(_resp_s = undefined){
    if (_resp_s !== undefined){
      this._resp_s = _resp_s;
    } else {
      return this._resp_s;
    }
  }
  function errorResponseKeeper(_resp_e = undefined){
    if (_resp_e !== undefined){
      this._resp_e = _resp_e;
    } else {
      return this._resp_e;
    }
  }

});
