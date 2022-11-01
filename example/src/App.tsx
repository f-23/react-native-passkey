import * as React from 'react';

import { StyleSheet, View, Button, TextInput, Alert } from 'react-native';
import { Passkey } from 'react-native-passkey';

export default function App() {
  const [email, setEmail] = React.useState('');
  const passkey = new Passkey('REPLACE IDENTIFIER', 'REPLACE DISPLAY NAME');

  async function createAccount() {
    try {
      const result = await passkey.register('PASS CHALLENGE', 'PASS USERID');

      console.log('Registration result: ', result);
    } catch (e) {
      console.log(e);
    }
  }

  async function authenticateAccount() {
    try {
      const result = await passkey.auth('PASS CHALLENGE');

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
