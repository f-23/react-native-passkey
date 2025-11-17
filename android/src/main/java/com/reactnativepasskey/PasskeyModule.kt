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
        val result = reactApplicationContext.currentActivity?.let { credentialManager.createCredential(it, createPublicKeyCredentialRequest) }

        val response =
          result?.data?.getString("androidx.credentials.BUNDLE_KEY_REGISTRATION_RESPONSE_JSON")
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
        return e.errorMessage.toString()
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
      else -> {
        return e.errorMessage.toString()
      }
    }
  }

  @ReactMethod
  fun get(requestJson: String, forcePlatformKey: Boolean, forceSecurityKey: Boolean, promise: Promise) {
      val credentialManager = CredentialManager.create(reactApplicationContext.applicationContext)
      val getCredentialRequest =
        GetCredentialRequest(listOf(GetPublicKeyCredentialOption(requestJson)))

      mainScope.launch {
        try {
          val result =
            reactApplicationContext.currentActivity?.let { credentialManager.getCredential(it, getCredentialRequest) }

          val response =
            result?.credential?.data?.getString("androidx.credentials.BUNDLE_KEY_AUTHENTICATION_RESPONSE_JSON")
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
        return e.errorMessage.toString()
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
        return e.errorMessage.toString()
      }
    }
  }
}
