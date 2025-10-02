import * as React from 'react';

import { StyleSheet, View, Button, TextInput, Alert } from 'react-native';
import { Passkey } from 'react-native-passkey';

const url = 'https://XYZ.ngrok-free.app'; // REPLACE with your domain (e.g. ngrok)

export default function App() {
  const [email, setEmail] = React.useState('');

  async function createAccount() {
    try {
      // Fetch the request object
      const response = await fetch(`${url}/auth/new`, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      });
      const requestJson = await response.json();

      // Perform passkey creation
      const result = await Passkey.create(requestJson);

      // Verify the response from the authenticator
      const verifyResponse = await fetch(`${url}/auth/new/verify`, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ ...result, platform: 'ios' }),
      });
      const verifyResponseJson = await verifyResponse.json();

      console.log('Create result: ', verifyResponseJson);
    } catch (e) {
      console.log(e);
    }
  }

  async function authenticateAccount() {
    try {
      // Fetch the request object
      const response = await fetch(`${url}/auth`, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      });
      const requestJson = await response.json();

      // Perform passkey assertion
      const result = await Passkey.get(requestJson);

      // Verify the response from the authenticator
      const verifyResponse = await fetch(`${url}/auth/verify`, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ ...result, platform: 'ios' }),
      });
      const verifyResponseJson = await verifyResponse.json();

      console.log('Get result: ', verifyResponseJson);
    } catch (e) {
      console.log(e);
    }
  }

  async function isSupported() {
    const result = Passkey.isSupported();
    Alert.alert(result ? 'Supported' : 'Not supported');
  }

  return (
    <View style={styles.container}>
      <TextInput placeholder="email" value={email} onChangeText={setEmail} />
      <Button title="Create Account" onPress={createAccount} />
      <Button title="Authenticate" onPress={authenticateAccount} />
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
