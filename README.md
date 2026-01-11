# @mccsoft/react-native-matomo


Matomo wrapper for React-Native. Supports Android and iOS. Fixed issues for native platforms build that are present in the official package.

**Supports multiple Matomo tracker instances** - you can track events to different Matomo servers or site IDs simultaneously.

---
## Installation
- Requires React Native version 0.60.0, or later.
- Supports: 
  - iOS: 11.0 and later
  - tvOS: 13.0 and later (using `react-native-tvos`)
  - Android SDK: 21 and later
- Supports Matomo SDK:
  - Android: 4.2
  - iOS/tvOS: 7.6.0

After that you can install it as usual.

Via NPM
```sh
npm install @mccsoft/react-native-matomo
```

Via Yarn
```sh
yarn add @mccsoft/react-native-matomo
```

Directly in package.json pointed to GitHub
```sh
"@mccsoft/react-native-matomo": "https://github.com/mccsoft/react-native-matomo",
```

#### :iphone:iOS (_Extra steps_)

```bash
cd ios/
# Install pod dependencies
pod install

```

Since the official [`matomo-sdk-ios`](https://github.com/matomo-org/matomo-sdk-ios) library is written is Swift, you need to have Swift enabled in your iOS project. If you already have any `.swift` files, you are good to go. Otherwise create a new empty Swift source file in Xcode, and allow it to create the neccessary bridging header when prompted.

## Quick usage

### Using MatomoTracker Class (Recommended)

The recommended way to use this library is through the `MatomoTracker` class, which supports multiple instances:

```js
import { MatomoTracker } from "@mccsoft/react-native-matomo";

// Create a tracker instance (default instance)
const tracker = new MatomoTracker();

// Initialize the tracker
await tracker.initialize("https://example.com/piwik.php", 1);

// Set user identification and custom dimensions
await tracker.setUserId("UniqueUserId");
await tracker.setCustomDimension(1, "1.0.0");

// Track events and views
await tracker.trackEvent("Application", "Startup");
await tracker.trackView("/start", "Start screen title");
```

### Multiple Tracker Instances

You can create multiple tracker instances to send data to different Matomo servers or site IDs:

```js
import { MatomoTracker } from "@mccsoft/react-native-matomo";

// Create tracker for production analytics
const productionTracker = new MatomoTracker("production");
await productionTracker.initialize("https://analytics.example.com/matomo.php", 1);

// Create tracker for internal analytics
const internalTracker = new MatomoTracker("internal");
await internalTracker.initialize("https://internal.example.com/matomo.php", 2);

// Track events to both trackers
await productionTracker.trackEvent("User", "Login");
await internalTracker.trackEvent("Debug", "LoginFlow");

// Stop a tracker when no longer needed
await internalTracker.stop({ dispatchRemaining: true });
```

### Legacy Usage (Backward Compatible)

The old function-based API is still available for backward compatibility:

```js
import Matomo from "@mccsoft/react-native-matomo";

Matomo.initialize("https://example.com/piwik.php", 1)
  .catch(error => console.warn("Failed to initialize matomo", error))
  .then(() => Matomo.setUserId("UniqueUserId"))
  .then(() => Matomo.setCustomDimension(1, "1.0.0"))
  .then(async () => {
      await Matomo.trackEvent("Application", "Startup");

      await Matomo.trackView("/start", 'Start screen title');
    }
  )
```

## API Reference

### MatomoTracker Class

#### Constructor

```javascript
const tracker = new MatomoTracker(instanceId?: string);
```

- `instanceId` - Optional unique identifier for this tracker instance. Defaults to `'default'`.

#### Initialize

Before using any tracking function, the tracker must be initialized.

```javascript
await tracker.initialize('https://your-matomo-domain.tld/piwik.php', siteId, cachedQueue?);
```

- `apiUrl` - Your Matomo server URL
- `siteId` - Your site ID in Matomo
- `cachedQueue` - (iOS only) Whether to cache events on disk. Android always uses cached queue.

Or use the options object:

```javascript
await tracker.initializeWithOptions({
  apiUrl: 'https://your-matomo-domain.tld/piwik.php',
  siteId: 1,
  cachedQueue: true
});
```

#### Is Initialized

Check if the tracker is initialized:

```javascript
const isInit = await tracker.isInitialized();
```

#### Get Instance ID

Get the instance identifier:

```javascript
const id = tracker.getInstanceId();
```

#### Set User ID

Providing the tracker with a user ID lets you connect data collected from multiple devices and multiple browsers for the same user. A user ID is typically a non empty string such as username, email address or UUID that uniquely identifies the user. The User ID must be the same for a given user across all her devices and browsers.

If user ID is used, it must be persisted locally by the app and set directly on the tracker each time the app is started.

If no user ID is used, the SDK will generate, manage and persist a random id for you.

```javascript
await tracker.setUserId('123e4567-e89b-12d3-a456-426655440000');

// Clear user ID
await tracker.setUserId(null);
```

#### Custom Dimensions

The Matomo SDK currently supports Custom Dimensions for the Visit Scope. Using Custom Dimensions you can add properties to the whole visit, such as "Did the user finish the tutorial?", "Is the user a paying user?" or "Which version of the Application is being used?" and such. Before sending custom dimensions please make sure Custom Dimensions are [properly installed and documented](https://matomo.org/docs/custom-dimensions/). You will need the ID of your configured Dimension.

After that you can set a new Dimension:

```javascript
await tracker.setCustomDimension(1, 'abc');
```

Or remove an already set dimension:

```javascript
await tracker.setCustomDimension(1, null);
```

Reset all custom dimensions:

```javascript
await tracker.resetCustomDimensions();
```

Dimensions in the Visit Scope will be sent along every Page View or Event. Custom Dimensions are not persisted by the SDK and have to be re-configured upon application startup.

#### Track Screen Views

To send a screen view set the screen path and titles on the tracker:

```javascript
await tracker.trackView('/your_activity', 'Title');
```

#### Track Events

To collect data about user's interaction with interactive components of your app, like button presses or the use of a particular item in a game:

```javascript
await tracker.trackEvent('category', 'action', 'label', 1000);
```

Optionally you can pass also path / url:

```javascript
await tracker.trackEvent('category', 'action', 'label', 1000, 'https://pathToYourSite.com/Action/Label');
```

#### Track Goals

If you want to trigger a conversion manually or track some user interaction simply call the method trackGoal. Read more about what is a [Goal in Matomo](http://matomo.org/docs/tracking-goals-web-analytics/).

```javascript
await tracker.trackGoal(1, revenue);
```

#### Track App Downloads

If you want to track the app downloads, there is also a function to do that (only supported on Android):

```javascript
await tracker.trackAppDownload();
```

#### Track Site Search

Track internal 'site' searches. (Requires Site Search to be active in Matomo website settings) Parameters are `query`, `category` and `resultCount`:

```javascript
await tracker.trackSiteSearch('Query', 'Category', 10);
```

#### Setting App Opt Out

The MatomoTracker SDK supports opting out of tracking. Note that this flag must be set each time the app starts up and will default to false:

```javascript
await tracker.setAppOptOut(true);
```

#### Dispatch Events Manually

Sometimes there is a need to dispatch events manually:

```javascript
await tracker.dispatch();
```

#### Set Dispatch Interval

Change the automatic dispatch interval (in seconds):

```javascript
await tracker.setDispatchInterval(30);
```

#### Get Dispatch Interval

Get the current dispatch interval (in seconds):

```javascript
const interval = await tracker.getDispatchInterval();
```

#### Reset Tracker

Reset the user ID (generates a new visitor ID):

```javascript
await tracker.reset();
```

#### Stop Tracker

Stop and remove a tracker instance. Optionally dispatch remaining events before stopping:

```javascript
// Stop without dispatching remaining events
await tracker.stop();

// Stop and dispatch remaining events
await tracker.stop({ dispatchRemaining: true });
```

## Legacy Methods

For backward compatibility, the following function-based API is available. These functions use a default tracker instance internally.

> **Note:** These functions are deprecated. Please use the `MatomoTracker` class for new implementations.

#### Initialize

```javascript
Matomo.initialize('https://your-matomo-domain.tld/piwik.php', 1);
```

On Android events queue is by default cached on disk, so events are not lost when user close the app. On iOS by default events queue is saved in memory, however you can opt in to use cached queue on iOS as well by initializing tracker with third option:

```javascript
Matomo.initialize('https://your-matomo-domain.tld/piwik.php', 1, true);
```

#### Set User ID

```javascript
Matomo.setUserId('123e4567-e89b-12d3-a456-426655440000');
```

#### Custom Dimensions

```javascript
Matomo.setCustomDimension(1, 'abc');
```

Or remove an already set dimension:

```javascript
Matomo.setCustomDimension(1, null);
```

#### Track Screen Views

```javascript
Matomo.trackView('/your_activity', 'Title');
```

#### Track Events

```javascript
Matomo.trackEvent('category', 'action', 'label', 1000);
```

Optionally you can pass also path / url:

```javascript
Matomo.trackEvent('category', 'action', 'label', 1000, 'https://pathToYourSite.com/Action/Label');
```

#### Track Goals

```javascript
Matomo.trackGoal(1, revenue);
```

#### Track App Downloads

```javascript
Matomo.trackAppDownload();
```

#### Setting App Opt Out

```javascript
Matomo.setAppOptOut(true);
```

#### Is Initialized

```javascript
await Matomo.isInitialized();
```

#### Dispatch Events Manually

```javascript
Matomo.dispatch();
```

#### Set Dispatch Interval

```javascript
Matomo.setDispatchInterval(30);
```

#### Get Dispatch Interval

```javascript
await Matomo.getDispatchInterval();
```

#### Track Site Search

```javascript
Matomo.trackSiteSearch('Query', 'Category', 10);
```

#### Reset

```javascript
Matomo.reset();
```

#### Reset Custom Dimensions

```javascript
Matomo.resetCustomDimensions();
```

#### Stop

```javascript
Matomo.stop({ dispatchRemaining: true });
```

## Cache Queue Backward Compatibility

The cache queue system maintains backward compatibility:

- **Default instance**: Uses the original cache key format, so existing cached events are preserved when upgrading.
- **Named instances**: Use a unique cache key format (`{instanceId}_{siteId}`) to prevent cache conflicts between different tracker instances.
- **Android**: Uses the instance ID as the tracker name for non-default instances, allowing separate storage per instance.

## Mocking

Add this to mock specific function as you wish

```js
jest.mock('@mccsoft/react-native-matomo', () => ({
  MatomoTracker: jest.fn().mockImplementation(() => ({
    initialize: () => Promise.resolve(),
    isInitialized: () => Promise.resolve(true),
    trackEvent: () => Promise.resolve(),
    trackView: () => Promise.resolve(),
    trackGoal: () => Promise.resolve(),
    trackAppDownload: () => Promise.resolve(),
    trackSiteSearch: () => Promise.resolve(),
    setCustomDimension: () => Promise.resolve(),
    setUserId: () => Promise.resolve(),
    setAppOptOut: () => Promise.resolve(),
    dispatch: () => Promise.resolve(),
    setDispatchInterval: () => Promise.resolve(),
    getDispatchInterval: () => Promise.resolve(30),
    reset: () => Promise.resolve(),
    resetCustomDimensions: () => Promise.resolve(),
    stop: () => Promise.resolve(),
    getInstanceId: () => 'default',
  })),
  // Legacy API mocks
  initialize: () => Promise.resolve(),
  isInitialized: () => Promise.resolve(true),
  trackEvent: () => Promise.resolve(),
  trackView: () => Promise.resolve(),
  trackGoal: () => Promise.resolve(),
  trackAppDownload: () => Promise.resolve(),
  trackSiteSearch: () => Promise.resolve(),
  setCustomDimension: () => Promise.resolve(),
  setUserId: () => Promise.resolve(),
  setAppOptOut: () => Promise.resolve(),
  dispatch: () => Promise.resolve(),
  setDispatchInterval: () => Promise.resolve(),
  getDispatchInterval: () => Promise.resolve(30),
  reset: () => Promise.resolve(),
  resetCustomDimensions: () => Promise.resolve(),
  stop: () => Promise.resolve(),
}));
```

Or add this line in your jest `setupFiles` configuration to define default mocks.

```
  "setupFiles": [
    ...
    "./node_modules/@mccsoft/react-native-matomo/jestSetup.js"
  ],
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
