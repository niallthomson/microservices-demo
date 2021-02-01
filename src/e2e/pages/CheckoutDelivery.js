let Page = require('./Page');

class CheckoutDelivery extends Page {

  constructor(baseUrl) {
    super(baseUrl);
  }

  getPath() {
    return '/checkout';
  }

  async next() {
    return await element(by.id('checkoutForm')).element(by.css('.btn-primary')).click();
  };
}
module.exports = CheckoutDelivery;