var juggernaut = {
    subscribe: function(channel, callback) {
        var jug = new Juggernaut;
        jug.subscribe(channel, function(data) {
            callback(data);
        });
    }
};