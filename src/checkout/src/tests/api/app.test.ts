import { ExpressConfig } from '../../config/Express';
import * as request from 'supertest';

const app = new ExpressConfig();

const valid = {
  customerEmail: 'asdasd@asdasd.com',
  items: [
      {
          id: 'a1',
          quantity: 1,
          unitCost: 123,
          totalCost: 123
      },
      {
          id: 'b2',
          quantity: 3,
          unitCost: 123,
          totalCost: 369
      }
  ],
  shippingAddress: {
      'address1': '999 Main St.',
      'address2': '#123',
      'city': 'Sometown',
      'state': 'AB',
      'zip': '12345'
  },
  subtotal: 492
};

describe('health check endpoint', () => {
  it('should work', () => {
    return request(app.app).get('/health')
      .expect(200)
      .then((response) => {
        expect(response.text).toBe('OK');
      });
  });
});

describe('checkout does not exist', () => {
  it('should indicate not found', () => {
    return request(app.app).get('/checkout/123')
      .expect(404);
  });
});

describe('submit valid checkout', () => {
  it('should be accepted', () => {
    return request(app.app).post('/checkout/123')
      .send(valid)
      .set('Accept', 'application/json')
      .set('Content-Type', 'application/json')
      .expect('Content-Type', /json/) // Doesnt work??!
      .expect(200);
  });
});

describe('submit invalid checkout', () => {
  it('should be rejected', () => {
    return request(app.app).post('/checkout/456')
      .send({junk: true})
      .set('Accept', 'application/json')
      .set('Content-Type', 'application/json')
      .expect('Content-Type', /json/) // Doesnt work??!
      .expect(400)
      .then((response) => {
        expect(response.text).toContain('You have an error');
      });
  });
});