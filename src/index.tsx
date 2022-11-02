import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package '@mcctomsk/react-native-matomo' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ReactNativeMatomo = NativeModules.ReactNativeMatomo
  ? NativeModules.ReactNativeMatomo
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function initialize(apiUrl: string, siteId: number): Promise<void> {
  const normalizedUrlBase =
    apiUrl[apiUrl.length - 1] === '/'
      ? apiUrl.substring(0, apiUrl.length - 1)
      : apiUrl;

  return ReactNativeMatomo.initialize(normalizedUrlBase, siteId);
}

export function isInitialized(): Promise<boolean> {
  return ReactNativeMatomo.isInitialized();
}

export function trackView(route: string, title?: string) {
  return ReactNativeMatomo.trackView(route, title);
}

export function trackEvent(
  category: string,
  event: string,
  name?: string,
  value?: number
): Promise<void> {
  return ReactNativeMatomo.trackEvent(category, event, {
    name: name,
    value: value,
  });
}

export function trackGoal(goalId: number, revenue: number): Promise<void> {
  return ReactNativeMatomo.trackGoal(goalId, { revenue });
}

export function trackAppDownload(): Promise<void> {
  return ReactNativeMatomo.trackAppDownload();
}

export function setCustomDimension(
  id: number,
  value: string | null
): Promise<void> {
  return ReactNativeMatomo.setCustomDimension(id, value);
}

export function setUserId(userId: string | null): Promise<void> {
  return ReactNativeMatomo.setUserId(userId);
}

export function setAppOptOut(isOptedOut: boolean): Promise<void> {
  return ReactNativeMatomo.setAppOptOut(isOptedOut);
}

export default {
  initialize: initialize,
  isInitialized: isInitialized,
  trackView: trackView,
  trackEvent: trackEvent,
  trackGoal: trackGoal,
  trackAppDownload: trackAppDownload,
  setCustomDimension: setCustomDimension,
  setUserId: setUserId,
  setAppOptOut: setAppOptOut,
};
