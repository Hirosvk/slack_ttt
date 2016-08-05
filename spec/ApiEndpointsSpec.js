describe("Tic-Tac-Toe", function(){
// JSON response type


  describe("New Game", function(){
    it("starts the game with opponent's username as parameter, and returns the empty board");
    it("the starter can choose to go after the opponent");
    it("returns instruction message with invalid entry");
    it("returns error msg if the opponent's information is missing");
    it("returns error msg if a game is alreayd taking place in the channel");
    it("handles multiple games taking place in different channels");

    // Interactive Button
    it("askes if you want to abandon the previous game if there is a game in progress");
    it("the opponent has to accept the challenge before playing");

    // API
    it("returns error msg if the opponent is not logged in");
  });

  describe("Place Move", function(){
    it("takes the coordinates and returns the updated board");
    it("returns error msg to any moves other than the current player");
  });

  describe("game over", function(){
    it("returns the result if the game has been won");
    it("reutnrs the result if the game is a tie");
  });

  describe("Request Game Status", function(){
    it("returns the current board");
  });

  describe("Stats", function(){
    it("provides the recent games of the channel");
  });

  describe("cancel game", function(){
    it("the starter of the game can cancel the game");

    // Interactive Button
    it("to cancel the game, it requires the permission of the opponent");

    // API & Event Listener
    it("when the player logs out the game is automatically cancelled");
  });

})
