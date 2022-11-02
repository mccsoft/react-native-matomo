# @mcctomsk/react-native-matomo


Matomo wrapper for React-Native. Supports Android and iOS. Fixed issues for native platforms build that are present in the official package.

---
## Installation
- Requires React Native version 0.60.0, or later.
- Supports iOS 10.0, or later.

Via NPM
```sh
npm install @mcctomsk/react-native-matomo
```

Via Yarn
```sh
yarn add @mcctomsk/react-native-matomo
```

Directly in package.json pointed to github
```sh
"@mcctomsk/react-native-matomo": "https://github.com/mcctomsk/react-native-matomo",
```

#### :iphone:iOS (_Extra steps_)

```bash
cd ios/
# Install pod dependencies
pod install

```

Since the official [`matomo-sdk-ios`](https://github.com/matomo-org/matomo-sdk-ios) library is written is Swift, you need to have Swift enabled in your iOS project. If you already have any `.swift` files, you are good to go. Otherwise create a new empty Swift source file in Xcode, and allow it to create the neccessary bridging header when prompted.

## Quick usage

```js
import Matomo from "@mcctomsk/react-native-matomo";

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

## Methods

#### Initialize

Before using any function below, the tracker must be initialized.

```javascript
Matomo.initialize('https://your-matomo-domain.tld/piwik.php', 1);
```

#### Set User ID

Providing the tracker with a user ID lets you connect data collected from multiple devices and multiple browsers for the same user. A user ID is typically a non empty string such as username, email address or UUID that uniquely identifies the user. The User ID must be the same for a given user across all her devices and browsers. .
If user ID is used, it must be persisted locally by the app and set directly on the tracker each time the app is started.

If no user ID is used, the SDK will generate, manage and persist a random id for you.

```javascript
Matomo.setUserId('123e4567-e89b-12d3-a456-426655440000');
```

#### Custom Dimensions

The Matomo SDK currently supports Custom Dimensions for the Visit Scope. Using Custom Dimensions you can add properties to the whole visit, such as "Did the user finish the tutorial?", "Is the user a paying user?" or "Which version of the Application is being used?" and such. Before sending custom dimensions please make sure Custom Dimensions are [properly installed and documented](https://matomo.org/docs/custom-dimensions/). You will need the ID of your configured Dimension.

After that you can set a new Dimension,

```javascript
Matomo.setCustomDimension(1, 'abc');
```

or remove an already set dimension.

```javascript
Matomo.setCustomDimension(1, null);
```
Dimensions in the Visit Scope will be sent along every Page View or Event. Custom Dimensions are not persisted by the SDK and have to be re-configured upon application startup.

#### Track screen views

To send a screen view set the screen path and titles on the tracker.

```javascript
Matomo.trackView('/your_activity', 'Title');
```

#### Track events

To collect data about user's interaction with interactive components of your app, like button presses or the use of a particular item in a game
use trackEvent.

```javascript
Matomo.trackEvent('category', 'action', 'label', 1000);
```

#### Track goals

If you want to trigger a conversion manually or track some user interaction simply call the method trackGoal. Read more about what is a [Goal in Matomo](http://matomo.org/docs/tracking-goals-web-analytics/).

```javascript
Matomo.trackGoal(1, revenue);
```

#### Track App Downloads

If you want to track the app downloads, there is also a function to do that (only supported on Android).

```javascript
Matomo.trackAppDownload();
```

#### Setting App Opt Out

The MatomoTracker SDK supports opting out of tracking. Note that this flag must be set each time the app starts up and will default to false. To set the app-level opt out, use:

```javascript
Matomo.setAppOptOut(true);
```

#### Is initialized
You can easily find out is Matomo tracker initialized or not. Call this method and get `Boolean` value, use:

```javascript
await Matomo.isInitialized();
```

### Mocking

Add this line in your jest `setupFiles` configuration option from `package.json`

```
  "setupFiles": [
    ...
    "./node_modules/@mcctomsk/react-native-matomo/jest.setup.js"
  ],
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
