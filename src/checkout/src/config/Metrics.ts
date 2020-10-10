import * as promMid from 'express-prometheus-middleware';

export function setupMetrics(app) {
  setupExpress(app);
};

function setupExpress(app) {
  app.use(promMid({
    metricsPath: '/metrics',
    collectDefaultMetrics: true,
    requestDurationBuckets: [0.1, 0.5, 1, 1.5],
  }));
}