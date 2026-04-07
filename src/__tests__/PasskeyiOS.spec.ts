// @ts-ignore
import { Platform, NativeModules } from 'react-native';
import { Passkey } from '../Passkey';
import type { PasskeyCreateRequest, PasskeyGetRequest } from '../PasskeyTypes';

import AuthRequestJson from './testData/AuthRequest.json';
import RegRequestJson from './testData/RegRequest.json';

const AuthRequest = AuthRequestJson as PasskeyGetRequest;
const RegRequest = RegRequestJson as PasskeyCreateRequest;

import AuthiOSResult from './testData/AuthiOSResult.json';
import RegiOSResult from './testData/RegiOSResult.json';

describe('Test Passkey Module', () => {
  beforeEach(() => {
    (Platform as any).setOS('ios');
    (Platform as any).setVersion('15.0');
  });

  test('should return unsupported for iOS Version below 15.0', async () => {
    (Platform as any).setVersion('14.2');

    expect(Passkey.isSupported()).toBeFalsy();
  });

  test('should call native register method', async () => {
    const registerSpy = jest
      .spyOn(NativeModules.Passkey, 'create')
      .mockResolvedValue(RegiOSResult);

    await Passkey.create(RegRequest);
    expect(registerSpy).toHaveBeenCalled();
  });

  test('should call native auth method', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockResolvedValue(AuthiOSResult);

    await Passkey.get(AuthRequest);
    expect(authSpy).toHaveBeenCalled();
  });
});
