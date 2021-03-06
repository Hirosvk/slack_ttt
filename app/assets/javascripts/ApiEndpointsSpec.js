describe("Tic-Tac-Toe Game", function(){
// make all error messages ephemeral

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
    responseContent(false);
  });

  describe("/challenge [opponent's username]", function(){

    describe("starts the game with opponent's username, and asks the opponent's consent", function(){
      beforeEach(function(done){
        challenge("Steve", "Silly", reset);
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().text).toMatch("Steve challenges Silly");
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });

    describe("if the challenged player accepts the game, it returns the empty gameboard", function(){
      beforeEach(function(done){
        challenge("Steve", "Silly", function(){
          accept("Silly", reset);
          function reset(){ resetCall(done) }
        });
      });
      it("spec", function(done){
        expect(responseContent().attachments[0].text).toMatch("This is a new game! It's Silly's turn");
        expect(responseContent().response_type).toEqual("in_channel");

        done();
      });
    });

    describe("the challenge expires in 1 minutes", function(){
      it("pending");
    });

    describe("allows only one challenge per channel at a time", function(){
      beforeEach(function(done){
        challenge("Steve", "Silly", function(){
          challenge("Jesse", "Mateo", reset);
          function reset(){ resetCall(done) }
        });
      });

      it("spec", function(done){
        expect(responseContent().text).toMatch("You cannot start a new game while there is a pending challenge");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("returns error msg if the opponent's username is missing", function(){
      beforeEach(function(done){
        defaultContent.user_name = "Steve";
        defaultContent.command = "/challenge";
        makeAjaxCall(defaultContent, reset);
        function reset(){ resetCall(done) }
      });

      it("spec", function(done){
        expect(responseContent().text).toMatch("You need to challenge another player");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("takes the first usrename if there are multiple usernames", function(){
      beforeEach(function(done){
        challenge("Lola", "nasley seiji silvie", reset)
        function reset(){ resetCall(done) }
      });

      it("spec", function(done){
        expect(responseContent().text).toMatch("Lola challenges nasley");
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });

    describe("returns error msg if a game is alreayd taking place in the channel", function(){
      beforeEach(function(done){
        challenge("Steve", "Silly", secondCall);
        function secondCall(){ accept("Silly", thirdCall); };
        function thirdCall(){ challenge("Hiro", "Dan", reset); };
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().text).toMatch("Only one game can take place per channel");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("handles multiple games taking place in different channels", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", anotherGame);
        function anotherGame(){
          setupGameWithAnotherChannel("Hiro", "Dan", reset);
        }
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().attachments[0].text).toMatch("This is a new game! It's Dan's turn")
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });
    // API
    it("returns error msg if the opponent is not logged in");
  });

  describe("/accept", function(){
    describe("when there is no challanges, it returns error msg", function(){
      beforeEach(function(done){
        accept("Steve", reset);
        function reset(){ resetCall(done) }
      });

      it("spec", function(done){
        expect(responseContent().text).toMatch("There is no challenge to accept");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    // Buttons
    it("lets users responde with buttons");
  });

  describe("/decline", function(){
    describe("returns the confirmation", function(){
      beforeEach(function(done){
        challenge("Steve", "Silly", function(){
          decline("Silly", reset);
          function reset(){ resetCall(done) }
        });
      });
      it("spec", function(done){
        expect(responseContent().text).toMatch("Silly declined the challenge from Steve");
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });

    describe("when there is no challanges, it returns error msg", function(){
      beforeEach(function(done){
        decline("Steve", reset);
        function reset(){ resetCall(done) }
      });

      it("spec", function(done){
        expect(responseContent().text).toMatch("There is no challenge to decline");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });
  });

  describe("/mark [position]", function(){
    describe("takes the position and returns the updated board", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          markBoard("Silly", "1", reset);
        })
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().attachments[0].text).toMatch("It's Steve's turn");
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });

    describe("returns error msg to the moves not by the wrong player", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          markBoard("Steve", "1", reset);
        });
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().text).toMatch("It's not your turn!");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("returns error msg to the moves by non-player", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          markBoard("Daniel", "1", reset);
        });
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().text).toMatch("You are not playing this game");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("returns error for invalid position", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          markBoard("Silly", "0", reset);
        })
        function reset(){ resetCall(done) }
      });
      it("spec - 0", function(done){
        expect(responseContent().text).toMatch("Please enter valid a positions");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("returns error for invalid position", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          markBoard("Silly", "20", reset);
        })
        function reset(){ resetCall(done) }
      });
      it("spec - 20", function(done){
        expect(responseContent().text).toMatch("Please enter valid a positions");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("returns error for invalid position", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          markBoard("Silly", "Milly", reset);
        })
        function reset(){ resetCall(done) }
      });
      it("spec - 'Milly'", function(done){
        expect(responseContent().text).toMatch("Please enter valid a positions");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("returns error msg if the place has been marked already", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          markBoard("Silly", "1", function(){
            markBoard("Steve", "1", reset);
          });
        });
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().text).toMatch("That space is already marked");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("if the move was the winning move, returns the result", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          setupNearWinGame("Steve", "Silly", function(){
            markBoard("Silly", "9", reset)
          });
        });
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().attachments[0].text).toMatch("Silly has won");
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });

    describe("if the move makes the game tie, it returns the result", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          setupNearTieGame("Steve", "Silly", function(){
            markBoard("Silly", "9", reset)
          });
        });
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().attachments[0].text).toMatch("It's a tie");
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });

    describe("when there is no game in progress, it returns error msg", function(){
      beforeEach(function(done){
        markBoard("Steve", "2", reset);
        function reset(){ resetCall(done) }
      });

      it("spec", function(done){
        expect(responseContent().text).toMatch("There is no game in progress");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });
  });


  describe("/abandon", function(){

    describe("Either of the players can abandon the game", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          abandon("Steve", reset)
        });
        function reset(){ resetCall(done) }
      });

      it("Steve abandons", function(done){
        expect(responseContent().text).toMatch("Steve abandoned the game");
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });

    describe("Either of the players can abandon the game", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          abandon("Silly", reset)
        });
        function reset(){ resetCall(done) }
      });

      it("Silly abandons", function(done){
        expect(responseContent().text).toMatch("Silly abandoned the game");
        expect(responseContent().response_type).toEqual("in_channel");
        done();
      });
    });


    describe("returns error message if you are not a player", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          abandon("Maria", reset)
        });
        function reset(){ resetCall(done) }
      });

      it("Maria tries to abandon", function(done){
        expect(responseContent().text).toMatch("Only the current players can abandon");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });

    describe("returns error message if no game is taking place.", function(){
      beforeEach(function(done){
        abandon("Silly", reset)
        function reset(){ resetCall(done) }
      });

      it("spec", function(done){
        expect(responseContent().text).toMatch("There is no game to abandon");
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    })

    // Buttons
    it("lets users choose yes/no with buttons");
    it("Asks for confirmation before abandonment");
    // API & Event Listener
    it("when the player logs out the game is automatically abandoned");
  });

  describe("/show_board", function(){
    describe("returns the board of the game in progress", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", function(){
          showBoard("Halal", reset);
        });
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().attachments[0].text).toMatch("It's Silly's turn")
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      });
    });
    describe("if no game is in progress, it returns the most recent game board and results", function(){
      beforeEach(function(done){
        setupGame("Steve", "Silly", secondCall);
        function secondCall(){ abandon("Silly", thirdCall) }
        function thirdCall() { showBoard("Halal", reset); }
        function reset(){ resetCall(done) }
      });
      it("spec", function(done){
        expect(responseContent().attachments[0].text).toMatch("This game was abandoned")
        expect(responseContent().response_type).toEqual("ephemeral");
        done();
      })

    });
  });


  describe("/how", function(){
    describe("returns the instruction of the game",function(){
      beforeEach(function(done){
        let content = Object.assign({}, defaultContent);
        content.user_name = "Jamal";
        content.command = "/how";
        makeAjaxCall(content, done);
      });
      it("spec", function(done){
        expect(responseContent().text).toMatch("How to play");
        done();
      })
    });
  });

  describe("/check", function(){
    describe("returns erro if there is no game",function(){
      beforeEach(function(done){
        let content = Object.assign({}, defaultContent);
        content.user_name = "Jamal";
        content.command = "/check";
        makeAjaxCall(content, done);
      });
      it("spec", function(done){
        expect(responseContent().text).toMatch("no game is taking place");
        done();
      })
    });
  });

  describe("handles GET request from Slack", function(){
    describe("return status 200 for GET request", function(){
      beforeEach(function(done){
        function _makeAjaxCall(callback){
          let request = new XMLHttpRequest();
          request.open("GET", window.path, true);
          request.onload = function(resp){
            responseContent(resp.target);
            if (callback) { callback(); }
          }
          request.send();
        };
        _makeAjaxCall(done)
      });
      it("spec", function(done){
        expect(responseContent().status).toEqual(200)
        console.log(responseContent());
        done();
      });
    });
  });

  // describe("/record", function(){
  //   it("provides the recent games' results");
  // });


// helper functions
  function setupGame(challenger, challenged, callback){
    let content = Object.assign({}, defaultContent);
    content.user_name = challenger;
    content.command = "/challenge";
    content.text = challenged;
    makeAjaxCall(content, secondCall);

    function secondCall(){
      let acceptContent = Object.assign({}, defaultContent);
      acceptContent.command = "/accept";
      acceptContent.user_name = challenged;
      makeAjaxCall(acceptContent, callback);
    }
  }

  function setupGameWithAnotherChannel(challenger, challenged, callback){
    let content = Object.assign({},defaultContent)
    content.user_name = challenger;
    content.command = "/challenge";
    content.text = challenged;
    content.channel_id = "12345";
    makeAjaxCall(content, secondCall);

    function secondCall(){
      let acceptContent = Object.assign({}, defaultContent);
      acceptContent.command = "/accept";
      acceptContent.user_name = challenged;
      acceptContent.channel_id = "12345";
      makeAjaxCall(acceptContent, callback);
    }
  }


  function markBoard(player, position, callback){
    let content = Object.assign({}, defaultContent);
    content.user_name = player;
    content.text = position;
    content.command = "/mark";
    makeAjaxCall(content, callback);
  }

  function accept(player, callback){
    let content = Object.assign({}, defaultContent);
    content.user_name = player;
    content.command = "/accept";
    makeAjaxCall(content, callback);
  }

  function decline(player, callback){
    let content = Object.assign({}, defaultContent);
    content.user_name = player;
    content.command = "/decline";
    makeAjaxCall(content, callback);
  }

  function challenge(challenger, challenged, callback){
    let content = Object.assign({}, defaultContent);
    content.user_name = challenger;
    content.command = "/challenge";
    content.text = challenged;
    makeAjaxCall(content, callback);
  }

  function abandon(player, callback){
    let content = Object.assign({}, defaultContent);
    content.user_name = player;
    content.command = "/abandon/";
    makeAjaxCall(content, callback);
  }

  function showBoard(user, callback){
    let content = Object.assign({}, defaultContent);
    content.user_name = user;
    content.command = "/show_board/";
    makeAjaxCall(content, callback);
  }

  function setupNearWinGame(challenger, challenged, callback){
    markBoard(challenged, "1", secondCall);
    function secondCall(){ markBoard(challenger, "4", thirdCall); }
    function thirdCall() { markBoard(challenged, "5", fourthCall); }
    function fourthCall(){ markBoard(challenger, "7", callback); }
  }

  function setupNearTieGame(challenger, challenged, callback){
    markBoard(challenged, "2", secondCall);
    function secondCall() { markBoard(challenger, "1", thirdCall); }
    function thirdCall()  { markBoard(challenged, "3", fourthCall); }
    function fourthCall() { markBoard(challenger, "6", fifthCall); }
    function fifthCall()  { markBoard(challenged, "4", sixthCall); }
    function sixthCall()  { markBoard(challenger, "7", seventhCall); }
    function seventhCall(){ markBoard(challenged, "5", eighthCall); }
    function eighthCall() { markBoard(challenger, "8", callback); }
  }

  function makeAjaxCall(content, successCallback){
    let request = new XMLHttpRequest();
    request.open("POST", window.path + content.command, true);
    request.onload = function(resp){
      if (request.status === 200){
        responseContent(JSON.parse(request.responseText));
        if (successCallback) { successCallback(); }
        // all responses are with status:200
      } else {
        console.log(resp);
        if (successCallback) { successCallback(); }
      }
    }
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.send(parseContent(content));
  };

  function resetCall(callback){
    let request = new XMLHttpRequest();
    request.open("POST", window.path + "/destroy_all", true);
    request.onload = function(resp){
      if (request.status === 200){
        callback();
      } else {
        console.log(resp);
      }
    }
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.send(parseContent(defaultContent));
  };

  function parseContent(content){
    let formatted = "";
    for(let propName in content){
      formatted += propName + "=" +
                   content[propName] + "&";
    }
    return formatted.slice(0,formatted.length-1);
  }

  function responseContent(_resp_s = undefined){
    if (_resp_s !== undefined){
      this._resp_s = _resp_s;
    } else {
      return this._resp_s;
    }
  }

});
