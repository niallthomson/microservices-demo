import * as winston from 'winston';

export const logger = winston.createLogger({
  transports: [
      new winston.transports.Console()
  ]
});

process.on('unhandledRejection', function(reason, p) {
  logger.warn('Possibly Unhandled Rejection at: Promise ', p, ' reason: ', reason);
});