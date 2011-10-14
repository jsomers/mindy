## How to start the application for development

1. Redis should be running. If it's not, try `redis-server /usr/local/etc/redis.conf`.
2. Start Juggernaut with `juggernaut`.
3. Start Rails with `rails s`.

## The Rules of Mindy Coat

* Four players, opposite sides are in teams. The action proceeds clockwise.
* Deal five cards each, starting with the player left of the dealer.
* That player calls trump based on his first five cards. No one else can see their five.
* Deal the rest of the cards.
* The rules follow those of a normal [trick-taking game](http://en.wikipedia.org/wiki/Trick-taking_game).
* Each trick counts for one point, and each ten counts for one additional point.
* The team with the most points at the end of thirteen tricks wins the round.
* Taking all four tens is called a "Mindy Coat" and immediately ends the game.

## TODOs

* Calculate the score and show it on the page. Don't forget about 10s!
* Show current trick in progress in its own little area.
* When you part, nil you out from your seat in the game. Pause the game -- i.e., disable all card actions. Whoever comes back to the game in progress occupies the first available seat.
* Handle the ending of the hand. Who won? Print trick history?
* What if a player changes his handle? The match should be keyed to ids, not handles.