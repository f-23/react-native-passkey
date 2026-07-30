// @ts-ignore
import { Platform, NativeModules } from 'react-native';
import { Passkey } from '../Passkey';
import { stringifyPasskeyRequest } from '../PasskeyRequest';
import type { PasskeyCreateRequest, PasskeyGetRequest } from '../PasskeyTypes';

import AuthRequestJson from './testData/AuthRequest.json';
import RegRequestJson from './testData/RegRequest.json';

const AuthRequest = AuthRequestJson as PasskeyGetRequest;
const RegRequest = RegRequestJson as PasskeyCreateRequest;

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

  test('should serialize Android PRF inputs as WebAuthn JSON', async () => {
    const registerSpy = jest
      .spyOn(NativeModules.Passkey, 'create')
      .mockResolvedValue(JSON.stringify(RegAndroidResult));

    await Passkey.create({
      ...RegRequest,
      excludeCredentials: [
        {
          id: 'wtHzWP5Mav6bQ+CH2241jg==',
          type: 'public-key',
        },
      ],
      extensions: {
        prf: {
          eval: {
            first: new Uint8Array([
              118, 50, 79, 56, 70, 82, 83, 95, 51, 78, 70, 118, 111, 104, 111,
              48, 51, 119, 87, 108, 79, 101, 109, 55, 111, 118, 65, 48, 79, 82,
              49, 76,
            ]),
          },
        },
      },
    });

    const nativeCall =
      registerSpy.mock.calls[registerSpy.mock.calls.length - 1];
    expect(nativeCall).toBeDefined();

    const nativeRequest = JSON.parse(nativeCall?.[0] as string);
    expect(nativeRequest.extensions.prf.eval.first).toBe(
      'djJPOEZSU18zTkZ2b2hvMDN3V2xPZW03b3ZBME9SMUw'
    );
    expect(nativeRequest.excludeCredentials[0].id).toBe(
      'wtHzWP5Mav6bQ-CH2241jg'
    );
  });

  test('should surface NoCreateOption when no provider can create a passkey', async () => {
    // Credential Manager raises CreateCredentialNoCreateOptionException when no credential
    // provider offers to create one — most commonly Google Password Manager with no Google
    // account signed in. Without an explicit mapping this fell through to `NativeError`,
    // whose `error` is the generic 'Native error', so callers could not detect the state to
    // fall back to a password flow.
    jest
      .spyOn(NativeModules.Passkey, 'create')
      .mockRejectedValue({ code: 'NoCreateOption' });

    await expect(Passkey.create(RegRequest)).rejects.toMatchObject({
      error: 'NoCreateOption',
    });
  });

  test('should call native auth method', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockResolvedValue(JSON.stringify(AuthAndroidResult));

    await Passkey.get(AuthRequest);
    expect(authSpy).toHaveBeenCalled();
  });

  test('should call native auth method with preferImmediatelyAvailable for getImmediate', async () => {
    const authSpy = jest
      .spyOn(NativeModules.Passkey, 'get')
      .mockResolvedValue(JSON.stringify(AuthAndroidResult));

    await Passkey.getImmediate(AuthRequest);
    expect(authSpy).toHaveBeenCalledWith(
      stringifyPasskeyRequest(AuthRequest, 'android'),
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
});
