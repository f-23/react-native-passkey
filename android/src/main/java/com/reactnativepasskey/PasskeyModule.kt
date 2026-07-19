package com.reactnativepasskey

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

import androidx.credentials.CredentialManager
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.exceptions.*
import androidx.credentials.exceptions.domerrors.*
import androidx.credentials.exceptions.publickeycredential.CreatePublicKeyCredentialDomException
import androidx.credentials.exceptions.publickeycredential.GetPublicKeyCredentialDomException

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

class PasskeyModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  private val mainScope = CoroutineScope(Dispatchers.Default)

  override fun getName(): String {
    return "Passkey"
  }

  @ReactMethod
  fun create(requestJson: String, forcePlatformKey: Boolean, forceSecurityKey: Boolean, promise: Promise) {
    val credentialManager = CredentialManager.create(reactApplicationContext.applicationContext)
    val createPublicKeyCredentialRequest = CreatePublicKeyCredentialRequest(requestJson)

    mainScope.launch {
      try {
        val activity = reactApplicationContext.currentActivity
          ?: run { promise.reject("RequestFailed", "No active Activity"); return@launch }

        val result = credentialManager.createCredential(activity, createPublicKeyCredentialRequest)

        val response =
          result.data.getString("androidx.credentials.BUNDLE_KEY_REGISTRATION_RESPONSE_JSON")
            ?: run { promise.reject("UnknownError", "Empty credential response"); return@launch }
        promise.resolve(response)
      } catch (e: CreateCredentialException) {
        val errorCode = handleRegistrationException(e)
        promise.reject(errorCode, errorCode)
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
      val credentialManager = CredentialManager.create(reactApplicationContext.applicationContext)
      val getCredentialRequest =
        GetCredentialRequest(
          listOf(GetPublicKeyCredentialOption(requestJson)),
          preferImmediatelyAvailableCredentials = preferImmediatelyAvailable
        )

      mainScope.launch {
        try {
          val activity = reactApplicationContext.currentActivity
            ?: run { promise.reject("RequestFailed", "No active Activity"); return@launch }

          val result = credentialManager.getCredential(activity, getCredentialRequest)

          val response =
            result.credential.data.getString("androidx.credentials.BUNDLE_KEY_AUTHENTICATION_RESPONSE_JSON")
              ?: run { promise.reject("UnknownError", "Empty credential response"); return@launch }
          promise.resolve(response)
        } catch (e: GetCredentialException) {
          val errorCode = handleAuthenticationException(e)
          promise.reject(errorCode, errorCode)
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
      is NotAllowedError -> "RequestFailed"
      is TimeoutError -> "TimedOut"
      is AbortError -> "UserCancelled"
      is DataError -> "RequestFailed"
      is NotSupportedError -> "NotSupported"
      else -> "UnknownError"
    }
  }
}
