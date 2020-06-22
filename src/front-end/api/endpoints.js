(function (){
  'use strict';

  var util = require('util');

  var domain = "";
  process.argv.forEach(function (val, index, array) {
    var arg = val.split("=");
    if (arg.length > 1) {
      if (arg[0] == "--domain") {
        domain = "." + arg[1];
        console.log("Setting domain to:", domain);
      }
    }
  });

  module.exports = {
    catalogueUrl:  util.format("http://catalogue%s:8080", domain),
    tagsUrl:       util.format("http://catalogue%s:8080/tags", domain),
    cartsUrl:      util.format("http://carts%s:8080/carts", domain),
    ordersUrl:     util.format("http://orders%s:8080", domain),
    customersUrl:  util.format("http://user%s:8080/customers", domain),
    addressUrl:    util.format("http://user%s:8080/addresses", domain),
    cardsUrl:      util.format("http://user%s:8080/cards", domain),
    loginUrl:      util.format("http://user%s:8080/login", domain),
    registerUrl:   util.format("http://user%s:8080/register", domain),
  };
}());
