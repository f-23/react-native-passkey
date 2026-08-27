import type {
  AuthenticationExtensionsPRFValues,
  PasskeyCreateRequest,
  PasskeyGetRequest,
} from './PasskeyTypes';

type PasskeyRequest = PasskeyCreateRequest | PasskeyGetRequest;
type EvalByCredential =
  | Record<string, AuthenticationExtensionsPRFValues>
  | Array<Record<string, AuthenticationExtensionsPRFValues>>;
type BinaryInput =
  | ArrayBuffer
  | ArrayLike<number>
  | Record<string, number>
  | string;

const base64UrlChars =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

export function stringifyPasskeyRequest(
  request: PasskeyRequest,
  platformOS: string
): string {
  if (platformOS !== 'android') {
    return JSON.stringify({
      ...request,
      extensions: normalizeExtensions(request.extensions),
    });
  }

  return JSON.stringify(normalizeAndroidRequest(request));
}

function normalizeAndroidRequest<T extends PasskeyRequest>(request: T): T {
  const normalized = {
    ...request,
    challenge: normalizeBase64UrlString(request.challenge),
  };

  if (isCreateRequest(request)) {
    return {
      ...normalized,
      user: {
        ...request.user,
        id: normalizeBase64UrlString(request.user.id),
      },
      excludeCredentials: request.excludeCredentials?.map(
        normalizeCredentialDescriptor
      ),
      extensions: normalizeExtensions(request.extensions),
    } as T;
  }

  return {
    ...normalized,
    allowCredentials: request.allowCredentials?.map(
      normalizeCredentialDescriptor
    ),
    extensions: normalizeExtensions(request.extensions),
  } as T;
}

function isCreateRequest(
  request: PasskeyRequest
): request is PasskeyCreateRequest {
  return 'user' in request;
}

function normalizeCredentialDescriptor<
  T extends NonNullable<
    | PasskeyCreateRequest['excludeCredentials']
    | PasskeyGetRequest['allowCredentials']
  >[number]
>(credential: T): T {
  return {
    ...credential,
    id: normalizeBase64UrlString(credential.id),
  };
}

function normalizeExtensions<
  T extends PasskeyCreateRequest['extensions'] | PasskeyGetRequest['extensions']
>(extensions: T): T {
  if (!extensions) {
    return extensions;
  }

  return {
    ...extensions,
    largeBlob: extensions.largeBlob
      ? {
          ...extensions.largeBlob,
          write:
            extensions.largeBlob.write === undefined
              ? undefined
              : binaryInputToBase64Url(extensions.largeBlob.write),
        }
      : undefined,
    prf: extensions.prf
      ? {
          ...extensions.prf,
          eval: normalizePrfValues(extensions.prf.eval),
          evalByCredential: normalizeEvalByCredential(
            extensions.prf.evalByCredential
          ),
        }
      : undefined,
  } as T;
}

function normalizePrfValues<
  T extends NonNullable<
    NonNullable<PasskeyCreateRequest['extensions']>['prf']
  >['eval']
>(values: T): T {
  if (!values) {
    return values;
  }

  return {
    ...values,
    first: binaryInputToBase64Url(values.first),
    second:
      values.second === undefined
        ? undefined
        : binaryInputToBase64Url(values.second),
  } as T;
}

function normalizeEvalByCredential(
  evalByCredential: EvalByCredential | undefined
): EvalByCredential | undefined {
  if (!evalByCredential) {
    return evalByCredential;
  }

  if (Array.isArray(evalByCredential)) {
    return evalByCredential.map(normalizeEvalByCredentialRecord);
  }

  return normalizeEvalByCredentialRecord(evalByCredential);
}

function normalizeEvalByCredentialRecord(
  evalByCredential: Record<string, AuthenticationExtensionsPRFValues>
): Record<string, AuthenticationExtensionsPRFValues> {
  return Object.fromEntries(
    Object.entries(evalByCredential).map(([credentialId, values]) => [
      normalizeBase64UrlString(credentialId),
      normalizePrfValues(values),
    ])
  );
}

function binaryInputToBase64Url(value: BinaryInput): string {
  if (typeof value === 'string') {
    return normalizeBase64UrlString(value);
  }

  if (isArrayBuffer(value)) {
    return bytesToBase64Url(new Uint8Array(value));
  }

  if (isArrayBufferView(value)) {
    return bytesToBase64Url(
      new Uint8Array(value.buffer, value.byteOffset, value.byteLength)
    );
  }

  if (Array.isArray(value)) {
    return bytesToBase64Url(value);
  }

  if (isNumberRecord(value)) {
    return bytesToBase64Url(
      Object.entries(value)
        .sort(([left], [right]) => Number(left) - Number(right))
        .map(([, byte]) => byte)
    );
  }

  return bytesToBase64Url(Array.from(value));
}

function normalizeBase64UrlString(value: string): string {
  return value.replace(/\+/g, '-').replace(/\//g, '_').replace(/[=]+$/g, '');
}

function bytesToBase64Url(bytes: ArrayLike<number>): string {
  let encoded = '';

  for (let index = 0; index < bytes.length; index += 3) {
    const first = bytes[index] ?? 0;
    const second = bytes[index + 1] ?? 0;
    const third = bytes[index + 2] ?? 0;

    encoded += base64UrlChars[first >> 2];
    encoded += base64UrlChars[((first & 3) << 4) | (second >> 4)];

    if (index + 1 < bytes.length) {
      encoded += base64UrlChars[((second & 15) << 2) | (third >> 6)];
    }

    if (index + 2 < bytes.length) {
      encoded += base64UrlChars[third & 63];
    }
  }

  return encoded;
}

function isArrayBuffer(value: unknown): value is ArrayBuffer {
  return typeof ArrayBuffer !== 'undefined' && value instanceof ArrayBuffer;
}

function isArrayBufferView(value: unknown): value is ArrayBufferView {
  return (
    typeof ArrayBuffer !== 'undefined' &&
    ArrayBuffer.isView(value) &&
    'buffer' in value &&
    value.buffer instanceof ArrayBuffer
  );
}

function isNumberRecord(value: unknown): value is Record<string, number> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    return false;
  }

  const entries = Object.entries(value);
  return (
    entries.length > 0 &&
    entries.every(
      ([key, entryValue]) => /^\d+$/.test(key) && typeof entryValue === 'number'
    )
  );
}
