import { ExpressConfig } from './Express';
import { logger } from '../common/logging';
import * as config from 'config';
import * as terminus from '@godaddy/terminus'

export class Application {

  server: any;
  express: ExpressConfig;

  constructor()  {
    this.express = new ExpressConfig();

    const port = config.get('port');

    const onHealthCheck = () => Promise.resolve('UP')

    const onSignal = () => {
      console.log('server is starting cleanup')
      return Promise.resolve()
    }
    
    const onShutdown = () => {
      console.log('cleanup finished, server is shutting down')
      return Promise.resolve()
    }

    const terminusConfiguration = {
      signal: 'SIGTERM',
      healthChecks: {
        '/health': onHealthCheck
      },
      onSignal,
      onShutdown
    };

    // Start Webserver
    this.server = this.express.app.listen(port, () => {
      logger.info(`Server started!`);
    });

    terminus.createTerminus(this.server, terminusConfiguration);
  }

}