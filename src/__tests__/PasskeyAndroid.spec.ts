// @ts-ignore
import { Platform, NativeModules } from 'react-native';
import { Passkey } from '../Passkey';

import AuthRequest from './testData/AuthRequest.json';
import RegRequest from './testData/RegRequest.json';

import AuthAndroidResult from './testData/AuthAndroidResult.json';
import RegAndroidResult from './testData/RegAndroidResult.json';

describe('Test Passkey Module', () => {
  beforeEach(() => {
    (Platform as any).setOS('android');
    (Platform as any).setVersion('33');
  });

  test('should return unsupported for Android Versions below 28', async () => {
    (Platform as any).setVersion('26');

    expect(await Passkey.isSupported()).toBeFalsy();
  });

  test('should call native register method', async () => {
    const registerSpy = jest
      .spyOn(NativeModules.Passkey, 'register')
      .mockResolvedValue(JSON.stringify(RegAndroidResult));

    await Passkey.register(RegRequest);
    expect(registerSpy).toHaveBeenCalled();
  });

  test('should call native auth method', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'authenticate')
      .mockResolvedValue(JSON.stringify(AuthAndroidResult));

    await Passkey.authenticate(AuthRequest);
    expect(authSpy).toHaveBeenCalled();
  });

  test('should call native register method with security key enabled', async () => {
    const registerSpy = jest
      .spyOn(NativeModules.Passkey, 'register')
      .mockResolvedValue(JSON.stringify(RegAndroidResult));

    await Passkey.register(RegRequest, {
      withSecurityKey: true,
    });
    expect(registerSpy).toHaveBeenCalled();
  });

  test('should call native auth method with security key enabled', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'authenticate')
      .mockResolvedValue(JSON.stringify(AuthAndroidResult));

    await Passkey.authenticate(AuthRequest, {
      withSecurityKey: true,
    });
    expect(authSpy).toHaveBeenCalled();
  });
});
