import * as express from 'express';
import * as cors from 'cors';
import * as health from 'express-ping';

import { useExpressServer, useContainer, getMetadataArgsStorage } from 'routing-controllers';
import { Container } from 'typedi';
import * as swaggerUiExpress from 'swagger-ui-express';

import { setupLogging } from './Logging';
import { setupMetrics } from './Metrics';
import { defaultMetadataStorage } from 'class-transformer/storage';
import { validationMetadatasToSchemas } from 'class-validator-jsonschema';
import { routingControllersToSpec } from 'routing-controllers-openapi';
import { CheckoutController } from '../controllers/CheckoutController';
import { CustomErrorHandler } from '../middlewares/CustomErrorHandler';

const routingControllerOptions = {
  controllers: [CheckoutController],
  middlewares: [CustomErrorHandler],
  defaultErrorHandler: false,
};

export class ExpressConfig {

  app: express.Express;

  constructor() {
    this.app = express();

    setupLogging(this.app);
    setupMetrics(this.app);

    this.app.use(cors());

    // Parse class-validator classes into JSON Schema:
    const schemas = validationMetadatasToSchemas({
      refPointerPrefix: '#/components/schemas/',
      classTransformerMetadataStorage: defaultMetadataStorage
    });

    // Parse routing-controllers classes into OpenAPI spec:
    const storage = getMetadataArgsStorage();
    const spec = routingControllersToSpec(storage, {
      controllers: [CheckoutController],
    }, {
      components: {
        schemas
      },
      info: {
        description: 'Checkout API',
        title: 'Checkout API',
        version: '1.0.0'
      },
      servers: [{
        url: 'http://localhost:8080'
      }]
    });

    this.app.use('/v2/api-ui', swaggerUiExpress.serve, swaggerUiExpress.setup(spec));

    this.app.get('/v2/api-docs', (_req, res) => {
      res.json(spec);
    });

    this.app.get('/health', function(_req, res) {
      res.send('OK');
    });

    this.setupControllers(routingControllerOptions);
  }

  setupControllers(routingControllerOptions) {
    useContainer(Container);

    useExpressServer(this.app, routingControllerOptions);
  }
}