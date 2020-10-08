import { ExpressConfig } from './Express';
import { logger } from '../common/logging';
import * as config from 'config';

export class Application {

  server: any;
  express: ExpressConfig;

  constructor()  {
    
    this.express = new ExpressConfig();

    const port = config.get('port');

    // Start Webserver
    this.server = this.express.app.listen(port, () => {
      logger.info(`Server started!`);
    });

    // Start Websockets
    //setupSockets(this.server);
  }

}