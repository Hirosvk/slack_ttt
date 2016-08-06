describe("Tic-Tac-Toe", function(){
// JSON response type


  describe("New Game", function(){
    it("starts the game with opponent's username as parameter, and asks the opponent's consent");
    it("upon the challenged player's consent, it returns the empty gameboard");
    it("the challenged player goes first");
    it("returns instruction message with invalid entry");
    it("returns error msg if the opponent's information is missing");
    it("returns error msg if a game is alreayd taking place in the channel");
    it("handles multiple games taking place in different channels");

    // Interactive Button --> make consent a button
    it("askes if you want to abandon the previous game if there is a game in progress");
    it("the opponent has to accept the challenge before playing");

    // API
    it("returns error msg if the opponent is not logged in");
  });

  describe("Place Move", function(){
    it("takes the position and returns the updated board");
    it("returns error msg to the moves not by the wrong player");
    it("returns error msg to the moves not by active player");
    it("returns error msg if the place has been marked already");
  });

  describe("game over", function(){
    it("returns the result if the game has been won");
    it("reutnrs the result if the game is a tie");
    it("after the game is over, it returns error msg if you try to make move");
  });

  describe("Request Game Status", function(){
    it("returns the current board of the game in progress");
    it("if no game is in progress, it returns the most recent game board and results");
  });

  // describe("Stats", function(){
  //   it("provides the recent games of the channel");
  // });

  describe("abandon game", function(){
    it("Either of the current players can abandon the game");
    it("Asks for confirmation before abandonment");

    // API & Event Listener
    it("when the player logs out the game is automatically abandoned");
  });

})
