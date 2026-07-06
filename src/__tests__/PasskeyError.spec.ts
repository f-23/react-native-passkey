import {
  handleNativeError,
  BadConfiguration,
  CredentialAlreadyExistsError,
  InterruptedError,
  NoCredentialsError,
  NotSupportedError,
  RequestFailedError,
  TimeoutError,
  UnknownError,
  UserCancelledError,
} from '../PasskeyError';
import type { PasskeyError } from '../PasskeyError';

describe('handleNativeError', () => {
  test('returns UnknownError when the native error has no code', () => {
    expect(handleNativeError({})).toEqual(UnknownError);
  });

  test.each<[string, PasskeyError]>([
    ['NotSupported', NotSupportedError],
    ['RequestFailed', RequestFailedError],
    ['UserCancelled', UserCancelledError],
    ['BadConfiguration', BadConfiguration],
    ['Interrupted', InterruptedError],
    ['NoCredentials', NoCredentialsError],
    ['TimedOut', TimeoutError],
    ['CredentialAlreadyExists', CredentialAlreadyExistsError],
    ['UnknownError', UnknownError],
  ])('maps native code "%s" to the matching PasskeyError', (code, expected) => {
    expect(handleNativeError({ code })).toEqual(expected);
  });

  test('wraps an unrecognized native code as a Native error', () => {
    expect(handleNativeError({ code: 'SomethingUnexpected' }).error).toBe(
      'Native error'
    );
  });
});
