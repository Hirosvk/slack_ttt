## best parts
I had no idea how versatile Slack custom integration was. It was great to get to know Slack in deeper level throughout the challenge. The challenge was very well thought-out to deepen candidates knowledge of the application.

It would also test candidates ability in many different levels. how to rollout an app server. how to take care of site security. how to design RESTful API.

Not only I was able to showcase my skills, it was a great learning experience for me.

The easy parts are MVC designs. I have experience in designing way more complicated web apps, and designing the structure and coding was not that difficult to me.

## difficult parts
Problem solving in this challenge was not that difficult compared to research. I feel that I have a strong problem solving skills, but I struggled because I did not know the convention of how things are done, and had to spend many hours for research.

One example was writing Jasmine specs. Though I used Jasmine before, I did not use it within Rails application. I spent many hours trying to make it work easily, but I ended up running as a single module instead of incorporating it in Rails, like Rails RSpec. I also spent a lot of time troubleshooting asynchronous AJAX requests. I kept trying to use waitsFor() and runs(), which I did not know that were deprecated. I searched through the source code since the error said that waitsFor() is not a function.

Another part that I struggled was CORS. I wanted to test API on the app on Heroku, but I had to learn how to properly implement CORS. I ended up using a very simple version without the "OPTION" request.

There were differences between development and production. Figuring out time-zone. Asset loading.

## TDD
I decided to write tests first because with my previous experience doing TDD, I ended up spending creating way better code. Since it was so pleasant, I am very interested in learning TDD, and the best way to do so is to write the test code on my own.
- results in better design -> I use specs as my planning document on what each component does. I would only write what I need.
- so easy to refactor and add features.
- with better design, aggressive refactoring, I ended up spending way less time in debugging / troubleshooting
- I really want to work for Slack, so it was critical for me that my app is robust, bug free. With spec file written, I could test nearly all possible cases.

After the whole project is done, I did a few manual testing as well, of course.

## what I learned

## what I would do differently
I could have worked on this project for a month, so I had to stop somewhere and turn it in when I felt that my work was good enough for the assignment.

Organizing the controller logics. On my current design, there are so many conditions that each controller method checks for. I would refactor and keep it dry by extracting conditionals into individual methods. Through that process, I might make the response into an instance variable. I would also make a simple view file in jbuilder format to take the response parsing logic out of the controller.

Make accept/decline buttons, in addition to reply features with slack commands.

Be able to mark the spot with buttons instead of commands. Is that possible?

## taking it further
Create User Model/table and join with Board Model. I would then make is so that users can see their past games' results. For example, with `/record [param]` command, users can see their past games with specific time period, opponents, or channels. I would need to make user_board join tables. Board 'has many(actually two)' players. Each player has many boards. User#recent_results. When initialing the game, the app should take user name as well as user_id so that we can track the same users on different teams.

Customize Slack-side's settings, and add emoji, for examples. Make it more fun and inviting.

Create a bot that you can play the game with. I would need to setup an AI on the app server, and setup an event listener on Slack channel. The game logic is relatively easy and have had experience in building AI.


## praise for Slack custom integration
I had no idea that these features were available. I makes me so excited to imagine what I can build. The documentation was very descriptive and clear, and I could find answers to nearly everything (except for a few things, see below). Designs were very simple and JSON style response was easy to arrange.

Open source: I saw that there is a community of developers contributing. I felt like I was invited to the community.

## Suggestions for Slack
Make the text more customizable. I felt that it was limiting that it only allows a few markdown commands and links. How about changing colors of text? More font features like underline, changing colors? Having built web app with HTML/CSS/JS, I felt that I have a very few options. Of course, I am not sure if it's a tech-constraint or intentional design decision.

Description of the integration options were excellently written. However, I was lost at times on how to do it actually. For example, I was looking for a way to get a token to access Slack API. I know that I had to build an app (so I did), but I could not figure out how to receive the token. I ended up using a Tester token, and I was fine for the purpose of the game.


## how to scale
Scaling the app
- I would closely look at the controller and minimize the number of times it hits the database. Optimize database query by pulling out the data on one query, and use the data.

Scaling the architecture
- Now it's running on Webrick server, which takes 50 reqs/sec. with hundreds and thousands of requests coming in to the app, I first need to upgrade the server and scale out by adding more servers and a load balancer. It doesn't have heavy assets, so CDN wouldn't be necessary, but if I would be using some picture files, then I would more them to CDN. I would need to setup external DB server. Denormalization of the SQL would not be good because this app does a lot of write. I don't know if caching makes sense, because the data changes so frequently as the game goes on... Most users would probably play the game, and checking the record would not be request frequently.

- If I have an AI for this app, then I would run in on a separate server so that AI's "thinking" doesn't slow down other operations.


## why PostgreSQL?
Heroku runs on PostgreSQL.

### why challenge and board tables?
The challenge has to be kept in DB until it's accepted, but once the game starts, we don't need that information. I could have just had one Board table, but there would be many challenges that won't be accepted. Also when someone accepts a challenge, the server has to search through the giant list of Boards, while if I have a smaller Challenge table, it's quicker to search. Also to implement 1-minute expiration on challenge, it was easy to do so if it has its own table. I ended up writing less lines of code this way.

### why Rails?
It's the most familiar web application framework for me.


## Why Slack?
- successful app with huge user base
- leader of messaging app(open source -> facilitate collaboration)
- exceptionally respectful to candidates --> it shows the high level of care the company provides to other aspect of the business like taking care of customers, employees, and quality of the products.
- respect was evident from the pricing model, too.
- so many different technologies(C++, PHP, JS, Go, Swift, C#, etc....)

- I am looking for a place where I can work for 5+ years, where I can keep challenging myself.
- as skilled entry-level engineer, I see a huge growth opportunity

## Why Slack now?
- I took a risk and learned software engineering
- I feel confident of my skills, and looking for a wonderful place to work.
- Electron: perfect next step for me: I know JS/HTML/CSS, but have little experience in building a desktop app.

## Why application engineering?
- I applied to Front End role as well. I am interested in any engineering role right now. I love algorithm-heavy backend stuff as much as I love creating beautiful design come to life in front end. Right now I just want to broaden my horizon in software engineering. I am looking for an amazing team of engineers to work with, where there are many challenges and growth opportunities.

## What am I looking for in this position?
- exciting and challenging project where I can put my skills to work. One of the main reason why I choose to change my career was to build tangible products to make difference.

## Achievement

## Failures


## How do I want to be managed?
I want to strike a good balance between guidance and independence with my manager. I consider myself to be a flexible team player, and I am open to different styles of management. It can get frustrating for me when expectations are not clear, and it leads to misunderstanding. I'm fine with my manager telling me, for example, that I have not earned his trust.

## How do I work with colleagues?


## Producing quality work


## Questions
- Can you give me a very brief overview of what Slacks' architecture looks like? What app server do you use? How much do you own as Slack?
- Can you tell me about the application engineering team? How many people? What is unique about the team besides what they build?
- How does your current role fulfill your professional goal?
