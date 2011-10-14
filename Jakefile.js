var fs = require('fs');

desc('Check and install required packages');
task('depends', [], function (arg) {
    var npm = require('npm');
    npm.load({}, function (err) {
        if (err) return commandFailed(err);
        npm.on("log", function (message) { if(arg) console.log(message) })
        var requirements = JSON.parse(fs.readFileSync('config/requirements.json'));
        npm.commands.install(requirements, function (err, data) {
            if (err) return commandFailed(err);
        });
    });
}, true);


