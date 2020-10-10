module.exports = {
  globals: {
      "ts-jest": {
          tsConfig: "tsconfig.json"
      }
  },
  moduleFileExtensions: [
      "ts",
      "js"
  ],
  transform: {
      "^.+\\.(ts|tsx)$": "ts-jest"
  },
  testMatch: [
      "**/dist/tests/**/*.test.(ts|js)"
  ],
  testEnvironment: "node"
};