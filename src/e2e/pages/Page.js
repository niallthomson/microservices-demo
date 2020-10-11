"use strict";

class Page {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }

  home() {
    element(by.id('menu-home')).click();
  };

  catalog() {
    element(by.id('menu-catalog')).click();
  };

  cart() {
    element(by.id('go-cart')).click();
  };

  async get(path) {
    return await browser.get(this.baseUrl+path);
  };

  async go() {
    return await browser.get(this.getUrl());
  };

  getTitle() {
    return browser.getTitle();
  };

  getBreadcrumb() {
    return element(by.css(".breadcrumb-item.active"))
  }

  getPath() {
    return "";
  }

  getUrl() {
    return this.baseUrl+this.getPath();
  }
}
module.exports = Page;
