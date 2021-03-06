browser.waitForAngularEnabled(false);
var baseUrl = browser.params.baseUrl

let CheckoutAddress = require('./pages/CheckoutAddress');
let CheckoutDelivery = require('./pages/CheckoutDelivery');
let CheckoutPayment = require('./pages/CheckoutPayment');
let CheckoutReview = require('./pages/CheckoutReview');
let CheckoutSuccess = require('./pages/CheckoutSuccess');
let Product = require('./pages/Product');

var checkoutAddress = new CheckoutAddress(baseUrl);
var checkoutDelivery = new CheckoutDelivery(baseUrl);
var checkoutPayment = new CheckoutPayment(baseUrl);
var checkoutReview = new CheckoutReview(baseUrl);
var checkoutSuccess = new CheckoutSuccess(baseUrl);
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

      expect(checkoutAddress.activeTab().getText())
        .toEqual('Address');
    });

    it('should process checkout address', async() => {
      await checkoutAddress.populate('John', 'Doe', 'jdoe@example.com', '123 Main Street', 'Santa Barbara', 'California', '95133');

      await checkoutAddress.next();

      expect(checkoutAddress.activeTab().getText())
        .toEqual('Delivery Method');

      await checkoutDelivery.populate('token1');

      await checkoutDelivery.next();

      expect(checkoutAddress.activeTab().getText())
        .toEqual('Payment Method');

      await checkoutPayment.populate('John Doe', '1234567890', '12/20', '123');

      await checkoutPayment.next();

      expect(checkoutAddress.activeTab().getText())
        .toEqual('Order Review');

      await checkoutReview.next();

      expect(checkoutSuccess.getBreadcrumb().getText())
        .toEqual('Order Placed');
    });
  });
});