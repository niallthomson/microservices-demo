browser.waitForAngularEnabled(false);

describe('Protractor Demo App', function() {
  it('should have a title', function() {
    browser.get('http://localhost');

    expect(browser.getTitle()).toEqual('Watchn');
  });
});