var { SpecReporter } = require('jasmine-spec-reporter');

exports.config = {
  framework: 'jasmine',
  seleniumAddress: 'http://localhost:4444/wd/hub',
  specs: ['*.spec.js'],
  params: {
    baseUrl: 'http://localhost'
  },
  capabilities: {
    browserName: 'chrome',
    chromeOptions: {
      args: ['--window-size=1024,768'] // Without this the responsive layout breaks navigation assumptions
    }
  },
  //directConnect: true,
  onPrepare: function () {
    //console logs configurations
    jasmine.getEnv().addReporter(new SpecReporter({
      displayStacktrace: 'all',      // display stacktrace for each failed assertion, values: (all|specs|summary|none) 
      displaySuccessesSummary: false, // display summary of all successes after execution 
      displayFailuresSummary: true,   // display summary of all failures after execution 
      displayPendingSummary: true,    // display summary of all pending specs after execution 
      displaySuccessfulSpec: true,    // display each successful spec 
      displayFailedSpec: true,        // display each failed spec 
      displayPendingSpec: false,      // display each pending spec 
      displaySpecDuration: false,     // display each spec duration 
      displaySuiteNumber: false,      // display each suite number (hierarchical) 
      colors: {
        success: 'green',
        failure: 'red',
        pending: 'yellow'
      },
      prefixes: {
        success: '✓ ',
        failure: '✗ ',
        pending: '* '
      },
      customProcessors: []
    }));
  }
}