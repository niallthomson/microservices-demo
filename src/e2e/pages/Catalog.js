const { element } = require('protractor');
let Page = require('./Page');

class Catalog extends Page {

  constructor(baseUrl) {
    super(baseUrl);
  }

  getPath() {
    return "/catalog";
  }

  tag(name) {
    element(by.css('.category-menu')).element(by.linkText(name)).click();
  };

  size(number) {
    element(by.css('.products-number')).element(by.linkText(number)).click();
  };

  page(number) {
    element(by.css('.pagination')).element(by.linkText(number)).click();
  }

  getProducts() {
    return element(by.css('.products')).all(by.css('.product'));
  }
}
module.exports = Catalog;