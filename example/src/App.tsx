import * as React from 'react';
import { Alert, Button, StyleSheet, Text, View } from 'react-native';
import Matomo from 'react-native-matomo';
import { useCallback } from 'react';

export default function App() {
  const [isInit, setInit] = React.useState<boolean>(false);
  const [isInitModule, setInitModule] = React.useState<boolean | null>(null);

  const actualize = useCallback(async () => {
    const isInitialized = await Matomo.isInitialized();
    setInitModule(isInitialized);

    return isInitialized;
  }, []);

  const initializeMatomo = useCallback(async () => {
    const isInitialized = await actualize();

    if (isInitialized) {
      Alert.alert('Matomo has already initialized');
    } else {
      Matomo.initialize('https://example.com/piwik.php', 1)
        .catch((error) => console.warn('Failed to initialize matomo', error))
        .then(async () => {
          setInit(true);

          Matomo.trackEvent('Application', 'Startup').catch((error: any) =>
            console.warn('Failed to track event', error)
          );

          await Matomo.trackView('start/welcome', 'Start screen title');
        });
    }
  }, [actualize]);

  return (
    <View style={styles.container}>
      <View style={styles.box}>
        <Text>Matomo init (local): {JSON.stringify(isInit)}</Text>
        <Text>Matomo init (module): {JSON.stringify(isInitModule)}</Text>
      </View>

      <View style={styles.footer}>
        <Button title={'Initialize Matomo'} onPress={initializeMatomo} />

        <Button title={'Actualize status'} onPress={actualize} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  box: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  footer: {
    flex: 1,
    alignSelf: 'center',
    justifyContent: 'flex-end',
    marginBottom: 40,
  },
});
