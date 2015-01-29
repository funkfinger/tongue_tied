
tongue_tied README - test
==================

[ ![Codeship Status for funkfinger/tongue_tied](https://codeship.com/projects/f02f65f0-88d1-0132-dcd4-3ae5e43a70a3/status?branch=master)](https://codeship.com/projects/59532)

About:
------

This should facilitate text message-based giveaways during events. Will use Twilio or something similar to send and receive messages.

Things to do:
-------------


### Fix

- fix the quiz responses - text message numbers enrolled in a quiz should get a quiz response - text message numbers not enrolled in a quiz should get a generic message or a keyword message
- decouple SMS functionality with app


### Basics

- ~~create a project~~
- ~~learn a little Github Flavored Markdown... (we'll see if this looks right...)~~
- ~~register on Twilio~~
- ~~figure out how to do config for Heroku~~
- ~~start a to-do list~~
- ~~implement Datamapper with PostgreSQL~~
- ~~other setup stuff...~~
- ~~save phone number, text body and any other data sent to app from Twilio (plus creation date)~~~


### Keywords

- keywords should be in their own model
- Text messages should have an associated keyword
- System keywords should be implemented
  - **STOP** deactivates
  - **HELP** lists available options (public)
  - **TT** admin functions probably followed by a user identifier...


### Raffle

- create lists of numbers based on the text body
- select winners randomly from list
- text winner list via Twilio
- mark number / list member as winner
- option to select winners that haven't already won

### Trivia

- enrollment in trivia game via text message
- send question via text to enrolled participants
- list incoming responses (list only responses to last question)
- choose winner (manually for now)
- send text to winner
- repeat....


### Other
- figure out DataMapper migrations for situations when model changes break database...

Misc.:
--------------------

Using foreman to start this with an .env file:

    foreman start

Run tests using foreman so that the environment variables get set:

    foreman run bundle exec ruby test/test_tongue_tied.rb

Run the tests using rake:

    foreman run bundle exec rake test

or more a little more simply, the default is test:

    foreman run bundle exec rake

Push to Heroku

    git push heroku master

Since this is an educational project for me, It's worthwhile to mention that there may be a commercial solution for something this already - Google pointed to http://xaffle.com/index.php/ and http://www.estartqatar.com/coupons.php (and others...)...

Codeship

environment variables may need to be set- here are some:

    export FOO=bar
    export TWILIO_ACCOUNT_SID=uh_uh
    export TWILIO_AUTH_TOKEN=nah
    export DB_FLAVOR=postgresql
    export DB_HOST=localhost
    export DB_PORT=5432
    export DB_NAME=test
    export DB_USER=user
    export DB_PASS=pass
    export BETWEXT_COOKIE=nope
    export PLIVO_AUTHID=uh_no
    export PLIVO_TOKEN=nill
    export TWITTER_OAUTH_CONSUMER_KEY=nada
    export TWITTER_OAUTH_CONSUMER_SECRET=zilch
    export FACEBOOK_APP_ID=zero
    export FACEBOOK_SECRET=goose_egg





LICENSE
--------------------

This software is released under the Unlicense. See the UNLICENSE file in this repository or http://unlicense.org for details.
