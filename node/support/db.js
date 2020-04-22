const { Pool } = require('pg');
const { config } = require('../config/pg');
const { log } = require('./log');

const client = new Pool(config);

const query = (q) => {
  log(`Querying DB: "${q}"`);
  return client.query(q);
};

module.exports = {
  query
};