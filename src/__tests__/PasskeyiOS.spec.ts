// @ts-ignore
import { Platform, NativeModules } from 'react-native';
import { Passkey } from '../Passkey';
import { stringifyPasskeyRequest } from '../PasskeyRequest';
import {
  AbortedError,
  NoCredentialsError,
  TimeoutError,
  UserCancelledError,
} from '../PasskeyError';
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

  // iOS reports both "no credential available" and a genuine dismissal as
  // ASAuthorizationError.canceled (1001) under immediate mediation; the native
  // layer separates them on whether a presentation anchor was requested. A
  // dismissal must stay UserCancelled so callers can tell that the device does
  // hold a passkey, matching Android's Credential Manager behaviour.
  test('should reject getImmediate with UserCancelled when the user dismisses the sheet', async () => {
    jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockRejectedValue({ code: 'UserCancelled' });

    await expect(Passkey.getImmediate(AuthRequest)).rejects.toEqual(
      UserCancelledError
    );
  });

  // The native layer enforces the request's own `timeout`, so it has to reach
  // the native request JSON unchanged.
  test('should pass the request timeout on and reject with TimedOut once it passes', async () => {
    const getSpy = jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockRejectedValue({ code: 'TimedOut' });

    await expect(
      Passkey.get({ ...AuthRequest, timeout: 120000 })
    ).rejects.toEqual(TimeoutError);
    expect(JSON.parse(getSpy.mock.calls[0][0]).timeout).toBe(120000);
});

  test('should call native cancel method', () => {
    const cancelSpy = jest.spyOn(NativeModules.Passkey, 'cancel');

    Passkey.cancel();
    expect(cancelSpy).toHaveBeenCalled();
  });

  test('should reject a cancelled request with Aborted', async () => {
    jest
      .spyOn(NativeModules.Passkey, 'create')
      .mockRejectedValue({ code: 'Aborted' });

    await expect(Passkey.create(RegRequest)).rejects.toEqual(AbortedError);
  });
});
