// @ts-ignore
import { Platform, NativeModules } from 'react-native';
import { Passkey } from '../Passkey';

import AuthRequest from './testData/AuthRequest.json';
import RegRequest from './testData/RegRequest.json';

import AuthiOSResult from './testData/AuthiOSResult.json';
import RegiOSResult from './testData/RegiOSResult.json';

describe('Test Passkey Module', () => {
  beforeEach(() => {
    (Platform as any).setOS('ios');
    (Platform as any).setVersion('15.0');
  });

  test('should return unsupported for iOS Version below 15.0', async () => {
    (Platform as any).setVersion('14.2');

    expect(await Passkey.isSupported()).toBeFalsy();
  });

  test('should call native register method', async () => {
    const registerSpy = jest
      .spyOn(NativeModules.Passkey, 'register')
      .mockResolvedValue(RegiOSResult);

    await Passkey.register(RegRequest);
    expect(registerSpy).toHaveBeenCalled();
  });

  test('should call native auth method', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'authenticate')
      .mockResolvedValue(AuthiOSResult);

    await Passkey.authenticate(AuthRequest);
    expect(authSpy).toHaveBeenCalled();
  });

  test('should call native register method with security key enabled', async () => {
    const registerSpy = jest
      .spyOn(NativeModules.Passkey, 'register')
      .mockResolvedValue(RegiOSResult);

    await Passkey.register(RegRequest, {
      withSecurityKey: true,
    });
    expect(registerSpy).toHaveBeenCalled();
  });

  test('should call native auth method with security key enabled', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'authenticate')
      .mockResolvedValue(AuthiOSResult);

    await Passkey.authenticate(AuthRequest, {
      withSecurityKey: true,
    });
    expect(authSpy).toHaveBeenCalled();
  });
});
