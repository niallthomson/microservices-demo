class CartItem {

  constructor(element) {
    this.element = element;
  }

  getName() {
    return this.element.element(by.css('.item-name')).element(by.css('a')).getText();
  }

  getPrice() {
    return this.element.element(by.css('.item-price')).getText();
  }

  getQuantity() {
    return this.element.element(by.css('.item-quantity')).getText();
  }

  async remove() {
    await this.element.element(by.css('.remove-item')).click()
  }
}
module.exports = CartItem;