import { ExpressConfig } from '../../config/Express';
import * as request from 'supertest';
import {expect} from 'chai'

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
      .then((res) => {
        expect(res.status).to.equal(200); 
        expect(res.text).to.equal('OK');
      });
  });
});

describe('checkout does not exist', () => {
  it('should indicate not found', () => {
    return request(app.app).get('/checkout/123')
    .then((res) => {
      expect(res.status).to.equal(404); 
    });
  });
});

describe('submit valid checkout', () => {
  it('should be accepted', () => {
    return request(app.app).post('/checkout/123/update')
      .send(valid)
      .set('Accept', 'application/json')
      .set('Content-Type', 'application/json')
      .then((res) => {
        expect(res.status).to.equal(200); 
        expect(res.get('Content-Type')).to.contain('json');
        expect(res.body.total).to.equal(valid.subtotal + res.body.tax);
      });
  });
});

describe('checkout does exist', () => {
  it('should be retrieved', () => {
    return request(app.app).get('/checkout/123')
    .then((res) => {
      expect(res.status).to.equal(200); 
      expect(res.get('Content-Type')).to.contain('json');
      expect(res.body.total).to.equal(valid.subtotal + res.body.tax);
    });
  });
});

describe('submit invalid checkout', () => {
  it('should be rejected', () => {
    return request(app.app).post('/checkout/456/update')
      .send({junk: true})
      .set('Accept', 'application/json')
      .set('Content-Type', 'application/json')
      .then((res) => {
        expect(res.status).to.equal(400); 
        expect(res.get('Content-Type')).to.contain('json');
        expect(res.body.message).to.contain('You have an error');
      });
  });
});