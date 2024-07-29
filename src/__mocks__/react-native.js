const ReactNative = {};

let _os = 'ios';
let _version = '15.0';

const Platform = {
  get OS() {
    return _os;
  },

  setOS: (os) => {
    _os = os;
  },

  get Version() {
    return _version;
  },

  setVersion: (version) => {
    _version = version;
  },

  select: () => {
    return;
  },
};

const NativeModules = {
  Passkey: {
    create: jest.fn(),
    get: jest.fn(),
  },
};

ReactNative.Platform = Platform;
ReactNative.NativeModules = NativeModules;

module.exports = ReactNative;
