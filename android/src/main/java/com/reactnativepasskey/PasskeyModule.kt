package com.reactnativepasskey

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

import androidx.credentials.CredentialManager
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.SignalAllAcceptedCredentialIdsRequest
import androidx.credentials.SignalUnknownCredentialRequest
import androidx.credentials.exceptions.*
import androidx.credentials.exceptions.domerrors.*
import androidx.credentials.exceptions.publickeycredential.CreatePublicKeyCredentialDomException
import androidx.credentials.exceptions.publickeycredential.GetPublicKeyCredentialDomException

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

import org.json.JSONArray
import org.json.JSONObject

class PasskeyModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  private val mainScope = CoroutineScope(Dispatchers.Default)

  override fun getName(): String {
    return "Passkey"
  }

  override fun invalidate() {
    mainScope.cancel()
    super.invalidate()
  }

  @ReactMethod
  fun create(requestJson: String, forcePlatformKey: Boolean, forceSecurityKey: Boolean, promise: Promise) {
    mainScope.launch {
      try {
        val credentialManager = CredentialManager.create(reactApplicationContext.applicationContext)
        val createPublicKeyCredentialRequest = CreatePublicKeyCredentialRequest(requestJson)
        val activity = reactApplicationContext.currentActivity
          ?: run { promise.reject("RequestFailed", "No active Activity"); return@launch }

        val result = credentialManager.createCredential(activity, createPublicKeyCredentialRequest)

        val response =
          result.data.getString("androidx.credentials.BUNDLE_KEY_REGISTRATION_RESPONSE_JSON")
            ?: run { promise.reject("UnknownError", "Empty credential response"); return@launch }
        promise.resolve(response)
      } catch (e: CreateCredentialException) {
        val errorCode = handleRegistrationException(e)
        promise.reject(errorCode, e.errorMessage?.toString() ?: errorCode)
      } catch (e: CancellationException) {
        throw e
      } catch (e: Throwable) {
        promise.reject("UnknownError", e.message ?: "UnknownError")
      }
    }
  }

  private fun handleRegistrationException(e: CreateCredentialException): String {
    e.printStackTrace()
    when (e) {
      is CreatePublicKeyCredentialDomException -> {
        return mapDomError(e.domError)
      }
      is CreateCredentialCancellationException -> {
        return "UserCancelled"
      }
      is CreateCredentialInterruptedException -> {
        return "Interrupted"
      }
      is CreateCredentialProviderConfigurationException -> {
        return "NotConfigured"
      }
      is CreateCredentialUnknownException -> {
        return "UnknownError"
      }
      is CreateCredentialUnsupportedException -> {
        return "NotSupported"
      }
      is CreateCredentialNoCreateOptionException -> {
        // No credential provider offered to create a passkey — e.g. Google Password Manager
        // with no Google account signed in, or no provider installed at all. Without a stable
        // code here the JS side only receives the localized errorMessage, which it cannot
        // branch on to offer a password fallback.
        return "NoCreateOption"
      }
      else -> {
        // Fall back to the androidx type constant rather than the human-readable message:
        // `type` is a stable identifier, `errorMessage` is display text that may change.
        return e.type
      }
    }
  }

  @ReactMethod
  fun get(requestJson: String, forcePlatformKey: Boolean, forceSecurityKey: Boolean, preferImmediatelyAvailable: Boolean, promise: Promise) {
      mainScope.launch {
        try {
          val credentialManager = CredentialManager.create(reactApplicationContext.applicationContext)
          val getCredentialRequest =
            GetCredentialRequest(
              listOf(GetPublicKeyCredentialOption(requestJson)),
              preferImmediatelyAvailableCredentials = preferImmediatelyAvailable
            )
          val activity = reactApplicationContext.currentActivity
            ?: run { promise.reject("RequestFailed", "No active Activity"); return@launch }

          val result = credentialManager.getCredential(activity, getCredentialRequest)

          val response =
            result.credential.data.getString("androidx.credentials.BUNDLE_KEY_AUTHENTICATION_RESPONSE_JSON")
              ?: run { promise.reject("UnknownError", "Empty credential response"); return@launch }
          promise.resolve(response)
        } catch (e: GetCredentialException) {
          val errorCode = handleAuthenticationException(e)
          promise.reject(errorCode, e.errorMessage?.toString() ?: errorCode)
        } catch (e: CancellationException) {
          throw e
        } catch (e: Throwable) {
          promise.reject("UnknownError", e.message ?: "UnknownError")
        }
      }
  }

  /**
   * WebAuthn Signal API: tells OS credential managers a credential the relying party no longer
   * recognizes should be removed/hidden. `credentialId` is a base64url string; the platform
   * decodes it. Best-effort — resolves once the request is accepted.
   *
   * Use when unauthenticated / after a failed sign-in (single credential, no user handle). For the
   * authenticated full-set reconcile, use [signalAllAcceptedCredentials] instead.
   */
  @ReactMethod
  fun signalUnknownCredential(rpId: String, credentialId: String, promise: Promise) {
    mainScope.launch {
      try {
        val credentialManager = CredentialManager.create(reactApplicationContext.applicationContext)
        val requestJson = JSONObject().apply {
          put("rpId", rpId)
          put("credentialId", credentialId)
        }.toString()
        credentialManager.signalCredentialState(SignalUnknownCredentialRequest(requestJson))
        promise.resolve(null)
      } catch (e: CancellationException) {
        throw e
      } catch (e: Exception) {
        promise.reject("SignalFailed", e.message ?: "signalUnknownCredential failed", e)
      }
    }
  }

  /**
   * WebAuthn Signal API: reports the complete set of credential ids the relying party still
   * accepts for (rpId, userId); the credential manager removes any stored credentials not in the
   * list. `userId` and the ids are base64url strings. `allAcceptedCredentialIdsJson` is a
   * JSON-encoded array of base64url credential ids.
   *
   * Use when authenticated (needs the user handle + full accepted set); authoritatively prunes.
   * For a single credential when unauthenticated, use [signalUnknownCredential] instead.
   */
  @ReactMethod
  fun signalAllAcceptedCredentials(
    rpId: String,
    userId: String,
    allAcceptedCredentialIdsJson: String,
    promise: Promise
  ) {
    mainScope.launch {
      try {
        val credentialManager = CredentialManager.create(reactApplicationContext.applicationContext)
        val requestJson = JSONObject().apply {
          put("rpId", rpId)
          put("userId", userId)
          put("allAcceptedCredentialIds", JSONArray(allAcceptedCredentialIdsJson))
        }.toString()
        credentialManager.signalCredentialState(SignalAllAcceptedCredentialIdsRequest(requestJson))
        promise.resolve(null)
      } catch (e: CancellationException) {
        throw e
      } catch (e: Exception) {
        promise.reject("SignalFailed", e.message ?: "signalAllAcceptedCredentials failed", e)
      }
    }
  }

  private fun handleAuthenticationException(e: GetCredentialException): String {
    e.printStackTrace()
    when (e) {
      is GetPublicKeyCredentialDomException -> {
        return mapDomError(e.domError)
      }
      is GetCredentialCancellationException -> {
        return "UserCancelled"
      }
      is GetCredentialInterruptedException -> {
        return "Interrupted"
      }
      is GetCredentialProviderConfigurationException -> {
        return "NotConfigured"
      }
      is GetCredentialUnknownException -> {
        return "UnknownError"
      }
      is GetCredentialUnsupportedException -> {
        return "NotSupported"
      }
      is NoCredentialException -> {
        return "NoCredentials"
      }
      else -> {
        // Stable identifier over display text, same rationale as the create path.
        return e.type
      }
    }
  }

  private fun mapDomError(domError: DomError): String {
    return when (domError) {
      is InvalidStateError -> "CredentialAlreadyExists"
      is SecurityError -> "RequestFailed"
      is ConstraintError -> "BadConfiguration"
      // WebAuthn uses NotAllowedError as the (deliberately ambiguous) signal for a
      // user-aborted/cancelled ceremony. The Credential Manager / FIDO2 provider
      // surfaces a Back-button cancel as GetPublicKeyCredentialDomException(NotAllowedError)
      // rather than GetCredentialCancellationException, so treat it as a cancellation
      // (consistent with iOS .canceled and the web navigator.credentials convention).
      is NotAllowedError -> "UserCancelled"
      is TimeoutError -> "TimedOut"
      is AbortError -> "UserCancelled"
      is DataError -> "RequestFailed"
      is NotSupportedError -> "NotSupported"
      else -> "UnknownError"
    }
  }
}
