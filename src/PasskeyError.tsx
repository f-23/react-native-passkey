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
    'Passkeys are not supported on this device. iOS 15 and above is required to use Passkeys',
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

export const NotConfiguredError: PasskeyError = {
  error: 'NotConfigured',
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

export const NativeError = (
  message = 'An unknown error occurred'
): PasskeyError => {
  return {
    error: 'Native error',
    message: message,
  };
};

export function handleNativeError(_error: unknown): PasskeyError {
  if (typeof _error !== 'object') {
    return UnknownError;
  }

  const error = String(_error).split(' ')[1];

  switch (error) {
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
    case 'NotConfigured': {
      return NotConfiguredError;
    }
    case 'Interrupted': {
      return InterruptedError;
    }
    case 'NoCredentials': {
      return NoCredentialsError;
    }
    case 'UnknownError': {
      return UnknownError;
    }
    default: {
      return NativeError(String(_error));
    }
  }
}
