# Slack Tic-Tac-Toe
Slack Tic-Tac-Toe was created for [this Slack Channel][slack_link]. Please see [here][technical_note] for technical notes of the app..

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
  - Challenges expire in one minute.
  - You cannot challenge while there is a pending challenge in the channel.
  - You cannot challenge while there is a game in progress in the channel. Only one game can take place per channel at a time.

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
* For example, if you type `/accept challenge`, only `/accept` will be registered. Similarly, `/challenge this_user that_user` will setup a challenge only for 'this_user', and 'that_user' is ignored.

<a name="tech_note"></a>
## Technical notes

### App Server Backend
The app's backend was built on Ruby on Rails following the basic MVC principles (this game lacks the View, however). The database is run on PostgreSQL, and the application was deployed to and run by Heroku.

***Models:***
Most of the game logic is taken care of in the Models. Three models/SQL tables are used in this app. 'Challenge' and 'Board' models handle most of the game logic. Due to the simplicity of the application, 'Challenge' and 'Board' don't have associations to each other. Once a challenge is accepted, there is no need to access its information anymore. The boards table keeps such information as players' usernames, channel_id, the current_status of the board, and the status of the game.

'Credential' model handles the tokens necessary for the secure connections with Slack. The tokens for the incoming request from Slack and the token for Slack API are kept in credentials table.
* [schema][schema]
* [Board][board_model]
* [Challenge][challenge_model]
* [Credential][credential_model]

***Controller:***
'GamesController' is handles all the incoming request regarding the game. All public methods here correspond with the Slack slach commands (`/challenge` => `GamesController#challenge`, for example). Most of them have the same functionality; they verify the request and either execute the game action or send back an error message. I tried to provide descriptive messages to which users would intuitively respond.

`#check` and `#challenge` calls the private method `#get_team_user_status`, which sends a request to Slack API and gets all users presence status. `#get_team_user_status` handles possible connection errors with Slack API, and returns the error message.
* [GamesController][GamesController]


### API Endpoints
All incoming requests are done by POST request so that when (or if) I bundle the game into a Slack App, I won't have to change the router. (I read that Slack App only sends POST requests). Each slash command name matches the names of the route and controller method.

domain: https://hiro-slack-ttt.herokuapp.com/
- POST api/games/challenge => GamesController#challenge
- POST api/games/accept => GamesController#accept
- POST api/games/decline => GamesController#decline
- POST api/games/mark => GamesController#mark
- POST api/games/abandon => GamesController#abandon
- POST api/games/show_board => GamesController#show_board
- POST api/games/check => GamesController#check
- POST api/games/how => GamesController#how

Additionally, it accepts GET request to any unmatched routes, and returns a response with the status 200 with a JSON message "Hi Slack people!".

### Security and Credentials
Slack Tic-Tac-Toe verify the parameter "token" for all incoming requests besides GET request. Tokens issued by Slack are stored in the server database, and any incoming requests from other sites without valid tokens will fail. Please see the code [here][slash_command_token]

When the app makes a request to Slack API, it retrieves the token from the database. The app uses Slack API Tester token, which, I think, is sufficient for the purpose of the assignment.

I needed to set up Cross Origin Resource Sharing when I was conducting the integration test and sending requests from my browser. However, I found out that it was unnecessary for the requests from Slack and commented out [this section][cors]

### Test Drive Development
I used TDD approach in creating my Slack Tic-Tac-Toe to achieve robust functionalities and to make refactoring/modification easier. Two rounds of testing was conducted during development: unit tests for the core models(Challenge and Board), and integration tests for API endpoints.

***Unit Test:***
These [RSpec files][rspec_files_folder] were written to thoroughly test the functions of the app's core models, Challenge and Board. All the specs were written before writing the models and used frequently throughout the development.

***Integration Test:***
This [jasmine spec][jasmine_file] tests API endpints. It sends actual HTTP requests to the server and verifies responses. I originally attempted using `runs()` and `waitsFor()` to properly tests the responses of asynchronous calls. However, I soon learned that they were deprecated features in newer versions of Jasmine. Instead, I  chained multiple function calls using callbacks, and by passing the optional `done()` callback on `beforeEach()` and `it()` blocks. [Reference][Jasmin_doc]

I ran the Jasmine spec in two spec runner; one to test the local server in the development environment, the other to test the production environment after the deployment to Heroku. Since the spec was not run in the test environment, I manually reset the database state with [this test-only controller method][games#destroy_all] so that all specs are run independently from the others.

After the initial implementation of the game, I changed the `#challenge` method slightly so that it makes a request to Slack API `users.list` to confirm the users' active status. The change is not reflected on the Jasmine specs, and I manually tested the new feature on the Slack Channels directly. Please note that many specs fail with the current implementation.

[technical_note]:#tech_note
[slack_link]:https://ae27583885test0.slack.com/messages/general/
[schema]:db/schema.rb
[board_model]:app/models/board.rb
[challenge_model]:app/models/challenge.rb
[credential_model]:app/models/challenge.rb
[GamesController]:app/controllers/api/games_controller.rb
[slash_command_token]:app/controllers/application_controller.rb
[cors]:app/controllers/api/games_controller.rb#L4
[rspec_files_folder]:spec/models
[jasmine_file]:app/assets/javascripts/ApiEndpointsSpec.js
[Jasmin_doc]:http://jasmine.github.io/2.4/introduction.html#section-Asynchronous_Support
[games#destroy_all]:app/controllers/api/games_controller.rb#L228
