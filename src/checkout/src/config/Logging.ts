import * as winston from 'winston';
import * as config from 'config';
import * as expressWinston from 'express-winston';

const level = config.get('loglevel');

export function setupLogging(app) {
  // Development Logger
  const env = config.util.getEnv('NODE_ENV');

  if(env !== 'test') {
    setupExpress(app);
  }
};

function setupExpress(app) {
  // error logging
  if(level === 'debug') {
    app.use(expressWinston.errorLogger({
      transports: [
        new winston.transports.Console()
      ]
    }));
  }

  // request logging
  if(level === 'info') {
    app.use(expressWinston.logger({
      transports: [
        new winston.transports.Console()
      ]
    }));
  }
};