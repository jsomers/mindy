## How to start the application for development

1. Redis should be running. If it's not, try `redis-server /usr/local/etc/redis.conf`.
2. Start Juggernaut with `juggernaut`.
3. Start Rails with `rails s`.

## The Rules of Mindy Coat

* The game is played with four players in teams of two, seated opposite. The action proceeds clockwise.
* Five cards are dealt to each player, starting with the player to the left of the dealer. That player's cards are dealt face-up, the rest face-down.
* The face-up player calls trump based on his first five cards. No one else can see their five.
* The rest of the cards are dealt.
* Players select one card each in a given turn (a "trick"). The team playing the highest-ranked card takes the trick. (See [trick-taking games](http://en.wikipedia.org/wiki/Trick-taking_game) more generally).
* Each trick counts for one point, and each of the four 10s counts for one additional point. There are 17 points total to be earned.
* The team with the most points at the end of thirteen tricks wins the round.
* Taking all four tens is called a "Mindy Coat" and is considered a total victory.

## TODOs

* Multiple people leaving at the same time, coming back, and not getting into the right empty seat (because of .first call) -- use their session handle instead of an arbitrary id in [empty][...].
* What if a player changes his handle? The match should be keyed to ids, not handles.
* Making pairs & current players clearer.
* "Play again" behavior.
* Deploy.
* Remodeling along the lines of a Backbone app? Think of separation of concerns and small models. What does each piece have to know?
* Clean code that has gotten dirty.
* Refactor the card code.
* Routing from / into a random game with people waiting. Players get a url to share. At 4 the rando joining stops, because the game is in progress.
* Multiple rounds?