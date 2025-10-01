const path = require('path');
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const root = path.resolve(__dirname, '..');
const exampleRoot = __dirname;
const moduleSrc = path.join(root, 'src');

const config = {
  projectRoot: exampleRoot,
  watchFolders: [root],

  resolver: {
    unstable_enableSymlinks: true,
    unstable_enablePackageExports: true,

    extraNodeModules: {
      'react-native-passkey': moduleSrc,
    },
  },
};

module.exports = mergeConfig(getDefaultConfig(exampleRoot), config);
