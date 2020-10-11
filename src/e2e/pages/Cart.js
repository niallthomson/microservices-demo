let Page = require('./Page');

class Cart extends Page {

  constructor(baseUrl) {
    super(baseUrl);
  }

  getPath() {
    return "/cart";
  }
}
module.exports = Cart;