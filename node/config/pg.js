const config = (process.env.DATABASE_URL)
  ?
    {
      connectionString: process.env.DATABASE_URL,
      ssl: true
    }
  :
    {
      database: process.env.DB_NAME,
      host: process.env.DB_HOST,
      password: process.env.DB_PASSWORD,
      user: process.env.DB_USERNAME
    };

module.exports = {
  config
};
