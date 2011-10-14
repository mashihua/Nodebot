var express = require('express');

var app = express.createServer();

app.use(express.static(__dirname + '/log'));

app.get('/', function(req, res){
  //the log will out put to log/{node_env}.log
  console.log("Method:" + req.method);
  //send text to agent
  res.send('Hello World. NODE_ENV=' + process.env.NODE_ENV);
});


//listening on application_port where set by capistrano
app.listen(process.argv[2] || 3000);