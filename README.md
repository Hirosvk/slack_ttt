# Slack Tic-Tac-Toe

## How to play
The available commands are `/challenge`, `/accept`, `/decline`, `/mark`, `/abandon`, `/show_board`, `/check`, and `/how`.
### To start a game
* First you need to challenge another user with `/challenge [username]` command.
* The command does not work if...
  - user is not a member of the team.
  - user is not logged-in ('active' status)
  - username is blank
* The challenge user either `/accept` or `/decline` the challenge. If the user accepts the challenge, the new game will begin.
* Notes:
  * Challenges expire in one minute.
  * You cannot challenge while there is a pending challenge in the channel.
  * You cannot challenge while there is a game in progress in the channel. Only one game can take place per channel at a time.

### While playing the game
* On you turn, place your mark with `/mark [position]`.
* valid entries are numbers from 1 to 9.
* Either of the players can always abandon the game with `/abandon`

### Checking the game status
* Any user, players or audience, can use `/show_board` to see the current status of the game.
* If no game is in progress, it shows the result of the most recent game.

### If players leave during the game...
* If players leave Slack without completing the game (or properly abandoning using `/abandon` command), other users cannot start a new game in the channel. `/check` command solves this problem!
* Any user, player or audience, can use `/check` command while a game is taking place. If both players are in 'active' status, the command does nothing. However, if any of the players has gone offline ('away' status), `/check` command cancels the game so that other users can start a new game.

### Quick Help
* You can get basic instructions with the `/how` command.

### Note on extra text
* If you add extra texts after the command, they will be ignored.
* For example, if you type `/accept challenge`, only `/accept` will be registered. Similarly, `/challenge this_user that_user` will create a challenge only for 'this_user', and 'that_user' is ignored.
