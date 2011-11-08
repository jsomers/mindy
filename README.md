## How to start the application for development

1. Redis should be running. If it's not, try `redis-server /usr/local/etc/redis.conf`.
2. Start Juggernaut with `juggernaut`.
3. Start Rails with `rails s`.

Problems with sqlite3? `bundle config build.sqlite3 --with-sqlite3-include=/usr/local/include --with-sqlite3-lib=/usr/local/lib --with-sqlite3-dir=/usr/local/bin`

## TODOs

* Stats, analytics, and cleaning up orphan games (cron job that calls rake task).
* Make a robot that plays the highest legal card, for testing purposes.
* People with the same handle?

* Remodeling along the lines of a Backbone app? Think of separation of concerns and small models. What does each piece have to know?
* An observer to publish records?
* Clean code that has gotten dirty.
* Refactor the card code.
* Write in pure node? No need to change the API, just the endpoint.

* Routing from / into a random game with people waiting. Players get a url to share. At 4 the rando joining stops, because the game is in progress.
* Multiple rounds?