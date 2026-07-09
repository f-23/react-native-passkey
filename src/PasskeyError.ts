export interface PasskeyError {
  error: string;
  message: string;
}

export const UnknownError: PasskeyError = {
  error: 'Unknown error',
  message: 'An unknown error occurred',
};

export const NotSupportedError: PasskeyError = {
  error: 'NotSupported',
  message:
    'Passkeys are not supported on this device. iOS 15 or Android SDK 28 and above is required to use Passkeys',
};

export const RequestFailedError: PasskeyError = {
  error: 'RequestFailed',
  message: 'The request failed. No Credentials were returned.',
};

export const UserCancelledError: PasskeyError = {
  error: 'UserCancelled',
  message: 'The user cancelled the request.',
};

export const InvalidChallengeError: PasskeyError = {
  error: 'InvalidChallenge',
  message: 'The provided challenge was invalid',
};

export const InvalidUserIdError: PasskeyError = {
  error: 'InvalidUserId',
  message: 'The provided userId was invalid',
};

export const BadConfiguration: PasskeyError = {
  error: 'BadConfiguration',
  message: 'Your app is not properly configured. Refer to the docs for help.',
};

export const NoCredentialsError: PasskeyError = {
  error: 'NoCredentials',
  message: 'No viable credential is available for the user.',
};

export const InterruptedError: PasskeyError = {
  error: 'Interrupted',
  message: 'The operation was interrupted and may be retried.',
};

export const TimeoutError: PasskeyError = {
  error: 'TimedOut',
  message: 'The operation timed out.',
};

export const CredentialAlreadyExistsError: PasskeyError = {
  error: 'CredentialAlreadyExists',
  message: 'A passkey for this account already exists on this device.',
};

export const NativeError = (
  message = 'An unknown error occurred'
): PasskeyError => {
  return {
    error: 'Native error',
    message: message,
  };
};

export interface TNativeError {
  code?: string;
  message?: string;
}

export function handleNativeError(_error: TNativeError): PasskeyError {
  if (!_error.code) {
    return UnknownError;
  }

  const mappedError = mapNativeErrorCode(_error.code, _error);

  // Preserve the native error message (e.g. "RP ID cannot be validated.")
  // when it carries more detail than the coarse error code, so callers can
  // diagnose configuration problems instead of only seeing the generic
  // fallback message for the mapped code.
  if (
    typeof _error.message === 'string' &&
    _error.message.length > 0 &&
    _error.message !== _error.code
  ) {
    return { ...mappedError, message: _error.message };
  }

  return mappedError;
}

function mapNativeErrorCode(code: string, _error: TNativeError): PasskeyError {
  switch (code) {
    case 'NotSupported': {
      return NotSupportedError;
    }
    case 'RequestFailed': {
      return RequestFailedError;
    }
    case 'UserCancelled': {
      return UserCancelledError;
    }
    case 'InvalidChallenge': {
      return InvalidChallengeError;
    }
    case 'BadConfiguration': {
      return BadConfiguration;
    }
    case 'Interrupted': {
      return InterruptedError;
    }
    case 'NoCredentials': {
      return NoCredentialsError;
    }
    case 'TimedOut': {
      return TimeoutError;
    }
    case 'CredentialAlreadyExists': {
      return CredentialAlreadyExistsError;
    }
    case 'UnknownError': {
      return UnknownError;
    }
    default: {
      return NativeError(String(_error));
    }
  }
}
