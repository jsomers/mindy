## How to start the application for development

1. Redis should be running. If it's not, try `redis-server /usr/local/etc/redis.conf`.
2. Start Juggernaut with `juggernaut`.
3. Start Rails with `rails s`.

## The Rules of Mindy Coat

* Four players, opposite sides are in teams.
* Deal 5 cards each, one-by-one starting left of the dealer.
* Left of the dealer calls trump looking at those 5.
* Dealer deals the last 8 cards out (starts on the left).
* Highest card of the trick wins, unless a trump is thrown, in which case the highest trump wins.
* Team that takes the most tens wins, unless each takes two, in which case the total number of tricks is counted.
* (Must follow suit unless you don't have it.)