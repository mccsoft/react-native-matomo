import * as React from 'react';

import { StyleSheet, Text, View } from 'react-native';
import {
  initialize,
  isInitialized,
  setCustomDimension,
  setUserId,
  trackEvent,
  trackView,
} from '@mcctomsk/react-native-matomo';

export default function App() {
  const [isInit, setInit] = React.useState<boolean>(false);
  const [isInitModule, setInitModule] = React.useState<boolean>(false);

  React.useEffect(() => {
    initialize('https://example.com/piwik.php', 1)
      .catch((error) => console.warn('Failed to initialize matomo', error))
      .then(() => setUserId('UniqueUserId'))
      .then(() => setCustomDimension(1, '1.0.0'))
      .then(() => {
        setInit(true);
        trackEvent('Application', 'Startup').catch((error: any) =>
          console.warn('Failed to track event', error)
        );

        trackView('/start', 'Start screen title').catch((error: any) =>
          console.warn('Failed to track screen', error)
        );
      });
  }, []);

  React.useEffect(() => {
    const asyncMethod = async () => {
      const result = await isInitialized();
      setInitModule(result);
    };

    asyncMethod();
  }, []);

  return (
    <View style={styles.container}>
      <Text>Matomo init (local): {isInit}</Text>
      <Text>Matomo init (module): {isInitModule}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
