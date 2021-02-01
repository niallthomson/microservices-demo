let Page = require('./Page');

class CheckoutAddress extends Page {

  constructor(baseUrl) {
    super(baseUrl);
  }

  getPath() {
    return '/checkout';
  }

  async populate(firstName, lastName, email, address, city, state, zip) {
    var EC = protractor.ExpectedConditions;

    await this.populateField('firstName', firstName);
    await this.populateField('lastName', lastName);
    await this.populateField('email', email);
    await this.populateField('address1', address);
    await this.populateField('city', city);
    await this.populateField('zip', zip);

    let stateEl = await element(by.cssContainingText('option', state));
    
    return stateEl.click();
  }

  async next() {
    return await element(by.id('checkoutForm')).element(by.css('.btn-primary')).click();
  };

  async populateField(name, value) {
    let el = await element(by.id(name));

    return el.sendKeys(value);
  }
}
module.exports = CheckoutAddress;