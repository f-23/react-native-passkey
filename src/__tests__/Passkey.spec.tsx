// @ts-ignore
import { Platform, NativeModules } from 'react-native';
import { Passkey } from '../Passkey';
import {
  InvalidChallengeError,
  InvalidUserIdError,
  PasskeyError,
} from '../PasskeyError';

describe('Test Passkey Module', () => {
  beforeEach(() => {
    (Platform as any).setOS('ios');
    (Platform as any).setVersion('15.0');
  });

  test('should return unsupported for android', async () => {
    (Platform as any).setOS('android');

    expect(await Passkey.isSupported()).toBeFalsy();
  });

  test('should return unsupported for iOS Version below 15.0', async () => {
    (Platform as any).setVersion('14.2');

    expect(await Passkey.isSupported()).toBeFalsy();
  });

  test('should fail registration without valid challenge', async () => {
    try {
      await new Passkey('Test', 'Test').register('', 'testUserId');
      expect(true).toEqual(false);
    } catch (_error) {
      const error = _error as PasskeyError;
      expect(error.error).toEqual(InvalidChallengeError.error);
      expect(error.message).toEqual(InvalidChallengeError.message);
    }
  });

  test('should fail registration without valid userId', async () => {
    try {
      await new Passkey('Test', 'Test').register('testChallenge', '');
      expect(true).toEqual(false);
    } catch (_error) {
      const error = _error as PasskeyError;
      expect(error.error).toEqual(InvalidUserIdError.error);
      expect(error.message).toEqual(InvalidUserIdError.message);
    }
  });

  test('should fail auth without valid challenge', async () => {
    try {
      await new Passkey('Test', 'Test').auth('');
      expect(true).toEqual(false);
    } catch (_error) {
      const error = _error as PasskeyError;
      expect(error.error).toEqual(InvalidChallengeError.error);
      expect(error.message).toEqual(InvalidChallengeError.message);
    }
  });

  test('should call native register method', async () => {
    const registerSpy = jest.spyOn(NativeModules.Passkey, 'register');

    await new Passkey('Test', 'Test').register('testChallenge', 'testUserId');
    expect(registerSpy).toHaveBeenCalled();
  });

  test('should call native auth method', async () => {
    const authSpy = jest.spyOn(NativeModules.Passkey, 'auth');

    await new Passkey('Test', 'Test').auth('testChallenge');
    expect(authSpy).toHaveBeenCalled();
  });
});
