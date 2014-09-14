var assert = require('assert');
var RSVP = require('rsvp');
var rsvpHash = RSVP.hash;

var RANKING_DB = 2; // http://www.rediscookbook.org/multiple_databases.html
var options = {};
var port = null;
var host = null;

var redis = require('redis').createClient(port, host, options);

redis.on('error', function(err) {
  console.error('Redis Ranking:', err);
});

var checkDb = function() {
  redis.select(RANKING_DB, function(err, res) {
    if (err) {
      setImmediate(checkDb);
    }
  });
};
checkDb();

var Ranking = module.exports = function() {
  if (! (this instanceof Ranking)) { // enforcing new
    return new Ranking();
  }
  assert.deepEqual(redis.selected_db, RANKING_DB); // make sure we write to RANKING_DB
};

Ranking.prototype.rank = function(data, callback) {
  if (!data || ! data.UUID || ! data.bestScore || ! data.countryCode) {
    return;
  }

  var scoreMembers = [data.bestScore, data.UUID];

  var promises = {
    world: new RSVP.Promise(function(resolve, reject) {
      redis.zadd.apply(redis, ['world'].concat(scoreMembers), function(err, res) {
        if (err) {
          reject(err);
        } else {
          resolve(res);
        }
        console.log(res);
      });
    }.bind(this)),
    country: new RSVP.Promise(function(resolve, reject) {
      redis.zadd.apply(redis, [data.countryCode].concat(scoreMembers), function(err, res) {
        if (err) {
          reject(err);
        } else {
          resolve(res);
        }
        console.log(res);
      });
    }.bind(this))
  };
  rsvpHash(promises).then(function(results) {
    callback(null, results);
  }).
  catch(function(errors) {
    callback(errors, {});
  });
};

Ranking.shutdown = redis.quit.bind(redis);
