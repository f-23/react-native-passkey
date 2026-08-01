// @ts-ignore
import { Platform, NativeModules } from 'react-native';
import { Passkey } from '../Passkey';
import { stringifyPasskeyRequest } from '../PasskeyRequest';
import { NoCredentialsError, UserCancelledError } from '../PasskeyError';
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

  test('should call native auth method with preferImmediatelyAvailable for getImmediate', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockResolvedValue(AuthiOSResult);

    await Passkey.getImmediate(AuthRequest);
    expect(authSpy).toHaveBeenCalledWith(
      stringifyPasskeyRequest(AuthRequest, 'ios'),
      true,
      false,
      true
    );
  });

  test('should call native signalUnknownCredential method', async () => {
    const signalSpy = jest
      .spyOn(NativeModules.Passkey, 'signalUnknownCredential')
      .mockResolvedValue(undefined);

    await Passkey.signalUnknownCredential({
      rpId: 'example.com',
      credentialId: 'Y3JlZA',
    });
    expect(signalSpy).toHaveBeenCalledWith('example.com', 'Y3JlZA');
  });

  test('should call native signalAllAcceptedCredentials method with stringified ids', async () => {
    const signalSpy = jest
      .spyOn(NativeModules.Passkey, 'signalAllAcceptedCredentials')
      .mockResolvedValue(undefined);

    await Passkey.signalAllAcceptedCredentials({
      rpId: 'example.com',
      userId: 'dXNlcg',
      allAcceptedCredentialIds: ['a', 'b'],
    });
    expect(signalSpy).toHaveBeenCalledWith(
      'example.com',
      'dXNlcg',
      JSON.stringify(['a', 'b'])
    );
  });

  test('should reject getImmediate with NoCredentials when no passkey is available', async () => {
    jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockRejectedValue({ code: 'NoCredentials' });

    await expect(Passkey.getImmediate(AuthRequest)).rejects.toEqual(
      NoCredentialsError
    );
  });

  test('should reject get with UserCancelled when the user cancels', async () => {
    jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockRejectedValue({ code: 'UserCancelled' });

    await expect(Passkey.get(AuthRequest)).rejects.toEqual(UserCancelledError);
  });
});
