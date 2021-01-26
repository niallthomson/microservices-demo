# End-to-End Tests

This component provides a suite of end-to-end tests that exercise a broad set of functionality of the application as a whole. They are designed to be cross-cutting and treat the application as a black box rather than a set of distinct components.

The tests are executed using `protractor`, and will run inside a headless Chrome browser.

## Prerequisites

The tests can be run in Docker, removing the need for most pre-requisites. All that is required for this mode is Docker to be installed locally.

Alternatively, to execute the tests directly the following components must be installed:
- NodeJS >= 12 & NPM
- Chrome web browser

## Running

There are two ways to run the tests.

### Docker

This is the easiest way to run the tests:

`./run-docker.sh 'http://endpoint:8080'`

Where the parameter should be adjusted to point at the endpoint of the UI service.

### NPM

The tests can be run using NPM:

```
npm install

npm test
```