# End-to-End Tests

This component provides a suite of end-to-end tests that exercise a broad set of functionality of the application as a whole. They are designed to be cross-cutting and treat the application as a black box rather than a set of distinct components.

The tests are executed using `protractor`, and will run inside a Chrome browser.

## Prerequisites

The following components must be installed:
- NodeJS + NPM
- Chrome web browser

## Running

First, update and start WebDriver by running:

```
npm install

npm run update:start-webdriver
```

Then, in a separate terminal run the tests:

```
npm test
```