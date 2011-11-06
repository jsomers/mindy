## How to start the application for development

1. Redis should be running. If it's not, try `redis-server /usr/local/etc/redis.conf`.
2. Start Juggernaut with `juggernaut`.
3. Start Rails with `rails s`.

Problems with sqlite3? `bundle config build.sqlite3 --with-sqlite3-include=/usr/local/include --with-sqlite3-lib=/usr/local/lib --with-sqlite3-dir=/usr/local/bin`

## TODOs

* Making pairs & current players clearer (maybe show current hand according to seating chart?).
* Waiting for other people to play -- make that clearer.
* "Play again" behavior.
* Release!
* Remodeling along the lines of a Backbone app? Think of separation of concerns and small models. What does each piece have to know?
* An observer to publish records?
* Clean code that has gotten dirty.
* Refactor the card code.
* Routing from / into a random game with people waiting. Players get a url to share. At 4 the rando joining stops, because the game is in progress.
* Multiple rounds?