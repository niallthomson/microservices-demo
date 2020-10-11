browser.waitForAngularEnabled(false);
var baseUrl = browser.params.baseUrl

let Cart = require('./pages/Cart');

var cart = new Cart(baseUrl);

describe('when on cart', function() {
  beforeAll(function() { 
    cart.go();
  });

  it('should have title', function() {
    expect(cart.getTitle()).toEqual('Watchn');
  });

  it('should have breadcrumb', function() {
    expect(cart.getBreadcrumb().getText())
      .toEqual('Shopping cart');
  });
});