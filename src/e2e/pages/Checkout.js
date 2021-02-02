let Page = require('./Page');

class Checkout extends Page {

  constructor(baseUrl) {
    super(baseUrl);
  }

  getPath() {
    return '/checkout';
  }

  activeTab() {
    return element(by.id('checkout')).element(by.css('.nav-link.active'));
  };

  async populateField(name, value) {
    let el = await element(by.id(name));

    await el.sendKeys(value);
  }

  async next() {
    return await element(by.id('checkoutForm')).element(by.css('.btn-primary')).click();
  };
}
module.exports = Checkout;