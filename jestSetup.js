jest.mock('@mcctomsk/react-native-matomo', () => ({
  initialize: jest.fn(),
  isInitialized: jest.fn(),
  setUserId: jest.fn(),
  setCustomDimension: jest.fn(),
  trackView: jest.fn(),
  trackEvent: jest.fn(),
  trackGoal: jest.fn(),
  trackAppDownload: jest.fn(),
  setAppOptOut: jest.fn(),
}));
