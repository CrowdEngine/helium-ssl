const express = require('express');
const db = require('./support/db');
const { log, lerror } = require('./support/log');

const DOMAIN_COLUMN = 'domain';
const DOMAIN_QUERY = (column, domain) => `SELECT 1 FROM platforms WHERE ${column} = '${escape(domain)}';`;
const SUBDOMAIN_COLUMN = 'subdomain';
const PORT = process.env.PORT;

const app = express();

// Handles shutting down on Heroku.
process
  .on('SIGTERM', shutdown('SIGTERM'))
  .on('SIGINT', shutdown('SIGINT'))
  .on('uncaughtException', shutdown('uncaughtException'));

function shutdown(signal) {
  return (err) => {
    log(`${ signal }...`);
    if (err) lerror(err.stack || err);
    setTimeout(() => {
      log('...waited 5s, exiting.');

      // Removes socket
      // const fs = require('fs');
      // try {
      //   fs.unlinkSync(PORT);
      // } catch(err) {
      //   lerror(err);
      // }

      // Exits
      process.exit(err ? 1 : 0);
    }, 5000).unref();
  };
}

const getHost = (domain) => {
  var domainParts = domain.split('.');
  return domainParts.slice(domainParts.length - 2).join('.');
};

const getSubdomain = (domain) => domain.split('.')[0];

const shouldUseSubdomain = (host) => host === process.env.DEFAULT_HOST;

// Logging middleware
app.use((req, res, next) => {
  log(`${req.method} on ${req.path} with params: ${JSON.stringify(req.params)}`);
  next();
});

// Request handler; checks if domain exists in DB
app.get('/domains/:domain', function (req, res) {
  const domain = req.params.domain;
  const host = getHost(domain);
  const column = shouldUseSubdomain(host) ? SUBDOMAIN_COLUMN : DOMAIN_COLUMN;
  const queryParam = shouldUseSubdomain(host) ? getSubdomain(domain) : domain;

  db
    .query(DOMAIN_QUERY(column, queryParam))
    .then(dbres => {
      if (dbres.rows[0]) {
        res.status(200).send('OK');
      } else {
        res.status(404).send('404');
      }
    })
    .catch(err => {
      lerror(err);
      res.status(500).send('500');
    });
});

// Launches server
app.listen(PORT, function () {
  log(`App listening on port ${PORT}...`);
});
