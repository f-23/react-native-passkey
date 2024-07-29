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

    expect(Passkey.isSupported()).toBeFalsy();
  });

  test('should call native register method', async () => {
    const registerSpy = jest
      .spyOn(NativeModules.Passkey, 'create')
      .mockResolvedValue(JSON.stringify(RegAndroidResult));

    await Passkey.create(RegRequest);
    expect(registerSpy).toHaveBeenCalled();
  });

  test('should call native auth method', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockResolvedValue(JSON.stringify(AuthAndroidResult));

    await Passkey.get(AuthRequest);
    expect(authSpy).toHaveBeenCalled();
  });
});
