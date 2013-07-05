tongue_tied README
==================

About:
------

This should facilitate text message-based giveaways during events. Will use Twilio or something similar to send and receive messages.

Things to do:
-------------

- ~~create a project~~
- ~~learn a little Github Flavored Markdown... (we'll see if this looks right...)~~
- ~~register on Twilio~~
- ~~figure out how to do config for Heroku~~
- ~~start a to-do list~~
- ~~implement Datamapper with PostgreSQL~~
- ~~other setup stuff...~~
- save phone number, text body and any other data sent to app from Twilio (plus creation date)
- create lists of numbers based on the text body
- select winners randomly from list
- text winner list via Twilio
- mark number / list member as winner
- option to select winners that haven't already won



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

Since this is an educational project for me, It's worthwhile to mention that there may be a commercial solution for something this already - Google pointed to http://xaffle.com/index.php/ and http://www.estartqatar.com/coupons.php (and others...)...

