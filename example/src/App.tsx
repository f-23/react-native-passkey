import * as React from 'react';

import { StyleSheet, View, Button, TextInput, Alert } from 'react-native';
import { Passkey } from 'react-native-passkey';

import RegRequest from '../../src/__tests__/testData/RegRequest.json';
import AuthRequest from '../../src/__tests__/testData/AuthRequest.json';

export default function App() {
  const [email, setEmail] = React.useState('');

  async function createAccount() {
    try {
      const requestJson = {
        // ...Retrieve request from server
        ...RegRequest,
      };

      const result = await Passkey.register(requestJson);

      console.log('Registration result: ', result);
    } catch (e) {
      console.log(e);
    }
  }

  async function authenticateAccount() {
    try {
      const requestJson = {
        // ...Retrieve request from server
        ...AuthRequest,
      };

      const result = await Passkey.authenticate(requestJson);

      console.log('Authentication result: ', result);
    } catch (e) {
      console.log(e);
    }
  }

  async function createAccountWithSecurityKey() {
    try {
      const requestJson = {
        // ...Retrieve request from server
        ...RegRequest,
      };

      const result = await Passkey.register(requestJson, {
        withSecurityKey: true,
      });

      console.log('Registration result: ', result);
    } catch (e) {
      console.log(e);
    }
  }

  async function authenticateAccountWithSecurityKey() {
    try {
      const requestJson = {
        // ...Retrieve request from server
        ...AuthRequest,
      };

      const result = await Passkey.authenticate(requestJson, {
        withSecurityKey: true,
      });

      console.log('Authentication result: ', result);
    } catch (e) {
      console.log(e);
    }
  }

  async function isSupported() {
    const result = await Passkey.isSupported();
    Alert.alert(result ? 'Supported' : 'Not supported');
  }

  return (
    <View style={styles.container}>
      <TextInput placeholder="email" value={email} onChangeText={setEmail} />
      <Button title="Create Account" onPress={createAccount} />
      <Button
        title="Create Account with Security Key"
        onPress={createAccountWithSecurityKey}
      />
      <Button title="Authenticate" onPress={authenticateAccount} />
      <Button
        title="Authenticate with Security Key"
        onPress={authenticateAccountWithSecurityKey}
      />
      <Button title="isSupported?" onPress={isSupported} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'space-evenly',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
