var fs = require('fs');
var http = require('http');
var log = require('util').log;
var express = require('express');
var compress = require('compression');
var logger = require('morgan');
var engines = require('consolidate');
var methodOverride = require('method-override');
var app = express();
var url = require('./url');
var toobusy = require('toobusy');
var Ranking = require('ranking');

var port = 80;
app.use(function(req, res, next) {
  if (app.get('gracefulExit')) {
    // Node does not allow any new connections after closing its server.
    // However, we need to force to close the keep-alive connections
    req.connection.setTimeout(1);
    res.send(502, 'Server is in the process of restarting.');
  } else if (toobusy()) { // middleware which blocks requests when we're too busy
    res.send(503, 'Server is too busy right now, sorry.');
  } else {
    next();
  }
});
app.use(logger());
app.use(compress());
app.use(methodOverride());
app.set('views', url.join(__dirname, 'views'));
app.use(express.static(url.join(__dirname, 'public')));
app.engine('html', engines.hogan);


app.all('*(php|http|admin)*', function(req, res) {
  // Do not do anything here, let the attackers hang until it times out :P
});

app.post('/score', function(req, res) {
  new Ranking().rank(req.data, function(err, data) {
    if (err) {
      console.error(err);
      res.send(500);
    } else {
      res.send(data);
    }
  });
});

app.all('*', function(req, res) {
  res.render('index.html', {
    title: 'Limily',
    subtitle: 'Feed Reader',
    slogan: 'brings you the best news',
    license: '&copy; 2014 limily.com All rights reserved except those specifically granted herein',
    blog: 'Blog',
    blogUrl: '//limilyapp.tumblr.com',
    privacy: 'Privacy and Terms',
    contact: 'Contact',
    contactEmail: 'mailto:info@limily.com',
    defaultTarget: '_blank',
    features: [
      'Simple intuitive UI',
      'Realtime intelligent news selection from feeds',
      'Cached news can be read even offline',
      'Open original website fast'
    ],
    description: 'Limily is an inteligent news feed reader mobile app. It learns your preference and reading behavior over time. To save your time, Limily automagically brings the most relevant and personalized news at the top of the list. Limily is the best learning tool for those who want to keep up with the newest technologies and trending.<br>Supported feed services: Feedly',
    pageImage: '/images/appicon.png',
    appStoreUrl: '#',
    appStoreBadge: '/images/Download_on_the_App_Store_Badge_US-UK_135x40.png',
    playUrl: '#', //'https://play.google.com/store/apps/details?id=com.limily',
    playBadge: '//developer.android.com/images/brand/en_generic_rgb_wo_60.png'
  });
});

var server = http.createServer(app).listen(port, function() {
  // if run as root, downgrade to the owner of this file
  if (process.getuid() === 0) {
    var stats = fs.statSync(__filename);
    process.setgid(stats.gid);
    process.setuid(stats.uid);
  }
  log('Webpage server listening to port ' + port);
});

var gracefulExit = function() {
  app.set('gracefulExit', true);
  server.close(function() {
    Ranking.shutdown(); // close redis
    process.exit();
  });
  // calling .shutdown allows your process to exit normally
  toobusy.shutdown();
};

process.on('SIGINT', gracefulExit);
process.on('SIGTERM', gracefulExit);
