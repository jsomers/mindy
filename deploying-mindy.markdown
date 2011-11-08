Follow this [guide](http://wtf.ejc.me/post/5679831003/fresh-setup-of-ubuntu-11-04-with-postgres-rvm-ruby), except ignore the stuff about postgres.

Server configuration should look like:

server {
	listen 80;
	server_name www.mindycoat.com;
	root /home/jsomers/www/mindy/public;
	passenger_enabled on;
}

Copy the ruby directory up to the server (`scp -r -P 30000 ~/projects/mindy jsomers@174.143.209.169:/home/jsomers/www/`).

Then follow the installation steps [here](http://purebreeze.com/2011/03/adding-realtime-push-updates-to-agileista-using-juggernaut/) just to install redis and node.

Install npm with `curl http://npmjs.org/install.sh | sudo sh`.

Install juggernaut with `sudo npm install -g juggernaut`.

Start the redis server: `redis-server`.

Start juggernaut: `juggernaut`.

Head to ~/www/mindy and get the bundle cooking, after creating the mindy gemset.

Try running rails in the console with RAILS_ENV = production.

Hook up git so that we can deploy from production.

Reload nginx with: `sudo ~/nginx/sbin/nginx -s reload`

Logs are at: `tail -f log/production.log`

Don't forget to precompile assets with: `bundle exec rake assets:precompile`.

Undo some of the iptables stuff to allow port 8080.

TODO: re-close some of the iptables.

TODO: git hooks.

## Juggernaut as a background process.

Use the guide here: https://gist.github.com/1055322.
And here: http://www.victorysawesome.com/blog/2011/05/18/using-monit-node-js-and-juggernaut-2-as-a-daemon/.
Try `sudo monit start juggernaut` and fight through errors. Permissions may be the problem. `sudo chmod a+rwx /var/...` for the pid file, for example.
Key is to use the "/etc/init.d/juggernaut start" in the monit /conf.d/juggernaut file.

## On deploy

1. git push, git pull.
2. redis-server &
3. juggernaut &
4. precompile assets.
5. sudo ~/nginx/sbin/nginx -s reload