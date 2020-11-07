const { createWriteStream } = require('fs');
let Page = require('./Page');
let CartItem = require('./CartItem')

class Cart extends Page {

  constructor(baseUrl) {
    super(baseUrl);
  }

  getPath() {
    return "/cart";
  }

  getItems() {
    return element(by.id('basket')).all(by.css('.cart-item'));
  }
}
module.exports = Cart;