module.exports = {
  preset: 'react-native',
  rootDir: __dirname,
  testMatch: [
    '<rootDir>/src/**/__tests__/**/*.[jt]s?(x)',
    '<rootDir>/src/**/*(*.)@(spec|test).[tj]s?(x)',
  ],
  modulePathIgnorePatterns: ['<rootDir>/example/node_modules', '<rootDir>/lib'],
  moduleDirectories: ['node_modules', 'src'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|@react-native-community)/.*)',
  ],
};
