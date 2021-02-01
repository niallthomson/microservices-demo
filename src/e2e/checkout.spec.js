browser.waitForAngularEnabled(false);
var baseUrl = browser.params.baseUrl

let CheckoutAddress = require('./pages/CheckoutAddress');
let CheckoutDelivery = require('./pages/CheckoutDelivery');
let Product = require('./pages/Product');

var checkoutAddress = new CheckoutAddress(baseUrl);
var checkoutDelivery = new CheckoutDelivery(baseUrl);
var product = new Product(baseUrl, '510a0d7e-8e83-4193-b483-e27e09ddc34d');

describe('when on checkout', function() {

  describe('with product in cart', function() {
    beforeAll(function() { 
      browser.manage().deleteAllCookies();

      product.go();
      product.addToCart();

      checkoutAddress.go();
    });

    it('should show checkout', function() {
      expect(browser.getCurrentUrl())
        .toBe(checkoutAddress.getUrl());
    });

    it('should process checkout address', function() {
      checkoutAddress.populate('John', 'Doe', 'jdoe@example.com', '123 Main Street', 'Santa Barbara', 'California', '95133');

      checkoutAddress.next();

      expect(browser.getCurrentUrl())
        .toBe(checkoutDelivery.getUrl());
    });
  });
});