tongue_tied
===========

This should facilitate text message-based giveaways during events. Will use Twilio or something similar to send and receive messages.

Things to do:
-------------

- [X] create a project
- [X] learn a little Github Flavored Markdown... (we'll see if this looks right...)
- [X] register on Twilio
- [X] figure out how to do config for Heroku
- [ ] implement Datamapper with PostgreSQL

Using foreman to start this with an .env file:
    foreman start

Run tests using foreman so that the environment variables get set:
    foreman run bundle exec ruby test/test_tongue_tied.rb
