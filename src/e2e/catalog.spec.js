browser.waitForAngularEnabled(false);
var baseUrl = browser.params.baseUrl

let Catalog = require('./pages/Catalog');

var catalog = new Catalog(baseUrl);

describe('when on catalog', function() {
  beforeAll(function() { 
    catalog.go();
  });

  it('should have title', function() {
    expect(catalog.getTitle()).toEqual('Watchn');
  });

  it('should have breadcrumb', function() {
    expect(catalog.getBreadcrumb().getText())
      .toEqual('Catalog');
  });

  it('should show products', function() {
    expect(catalog.getProducts().count())
      .toEqual(3);
  });

  describe('and select page', function() {
    beforeAll(function() { 
      catalog.go();
      catalog.page("2");
    });

    it('should show page', function() {
      expect(catalog.getProducts().count())
        .toEqual(3);
    });
  });

  describe('and select page size', function() {
    beforeAll(function() { 
      catalog.go();
      catalog.size("9");
    });

    it('should show products', function() {
      expect(catalog.getProducts().count())
        .toEqual(6);
    });

    describe('and select tag', function() {
      beforeAll(function() { 
        catalog.tag("Dress");
      });
  
      it('should filter products', function() {
        expect(catalog.getProducts().count())
          .toEqual(5);
      });
    });
  });

  describe('and select tag', function() {
    beforeAll(function() { 
      catalog.go();
      catalog.tag("Luxury");
    });

    it('should filter products', function() {
      expect(catalog.getProducts().count())
        .toEqual(1);
    });
  });
});