package com.mccsoft.reactnativematomo;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;

import org.matomo.sdk.Matomo;
import org.matomo.sdk.TrackMe;
import org.matomo.sdk.Tracker;
import org.matomo.sdk.TrackerBuilder;
import org.matomo.sdk.extra.CustomDimension;
import org.matomo.sdk.extra.TrackHelper;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@ReactModule(name = ReactNativeMatomoModule.NAME)
public class ReactNativeMatomoModule extends ReactContextBaseJavaModule {
  /** Default instance ID for backward compatibility */
  private static final String DEFAULT_INSTANCE_ID = "default";
  
  /** Map of tracker instances by instance ID */
  private Map<String, Tracker> trackers = new HashMap<>();
  
  /**
   * Custom dimensions per instance. These custom dimensions will get added to every tracking event.
   * This is how Matomo iOS SDK works.
   */
  private Map<String, Map<Integer, String>> customDimensionsMap = new HashMap<>();

  public static final String NAME = "ReactNativeMatomo";

  public ReactNativeMatomoModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void initialize(String instanceId, String apiUrl, int siteId, Promise promise) {
    try {
      Tracker existingTracker = trackers.get(instanceId);
      if (existingTracker == null) {
        TrackerBuilder builder;
        
        // For default instance, use createDefault for backward compatibility
        // For other instances, use custom tracker name
        if (DEFAULT_INSTANCE_ID.equals(instanceId)) {
          builder = TrackerBuilder.createDefault(apiUrl, siteId);
        } else {
          builder = new TrackerBuilder(apiUrl, siteId, instanceId);
        }
        
        Tracker newTracker = builder.build(Matomo.getInstance(getReactApplicationContext()));

        final String finalInstanceId = instanceId;
        Tracker.Callback callback = trackMe -> onTrackCallback(finalInstanceId, trackMe);
        newTracker.addTrackingCallback(callback);
        
        trackers.put(instanceId, newTracker);
        customDimensionsMap.put(instanceId, new HashMap<>());
      }

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void isInitialized(String instanceId, final Promise promise) {
    try {
      promise.resolve(trackers.get(instanceId) != null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void trackView(String instanceId, String route, @Nullable String title, Promise promise) {
    try {
      String actualTitle = title == null ? route : title;
      getTrackHelper(instanceId).screen(route).title(actualTitle).with(getTracker(instanceId));

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void trackEvent(String instanceId, String category, String action, ReadableMap optionalParameters, Promise promise) {
    try {
      TrackHelper.EventBuilder event = getTrackHelper(instanceId).event(category, action);
      if (optionalParameters.hasKey("name")) {
        event.name(optionalParameters.getString("name"));
      }
      if (optionalParameters.hasKey("value")) {
        event.value((float) optionalParameters.getDouble("value"));
      }
      if (optionalParameters.hasKey("url")) {
        event.path(optionalParameters.getString("url"));
      }

      event.with(getTracker(instanceId));

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void trackGoal(String instanceId, int goalId, ReadableMap values) {
    Float revenue = null;
    if (values.hasKey("revenue") && !values.isNull("revenue")) {
      revenue = (float) values.getDouble("revenue");
    }

    getTrackHelper(instanceId).goal(goalId).revenue(revenue).with(getTracker(instanceId));
  }

  @ReactMethod
  public void trackAppDownload(String instanceId) {
    Tracker tracker = trackers.get(instanceId);
    if (tracker != null) {
      getTrackHelper(instanceId).download().with(tracker);
    }
  }

  @ReactMethod
  public void setAppOptOut(String instanceId, Boolean isOptedOut, Promise promise) {
    try {
      Tracker tracker = trackers.get(instanceId);
      if (tracker != null) {
        tracker.setOptOut(isOptedOut);
        promise.resolve(null);
      } else {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void setUserId(String instanceId, String userId, Promise promise) {
    try {
      Tracker tracker = trackers.get(instanceId);
      if (tracker != null) {
        tracker.setUserId(userId);
        promise.resolve(null);
      } else {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void setCustomDimension(String instanceId, int dimensionId, @Nullable String value, Promise promise) {
    try {
      Map<Integer, String> dimensions = customDimensionsMap.get(instanceId);
      if (dimensions == null) {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
        return;
      }
      
      if (value != null && value.length() > 0) {
        dimensions.put(dimensionId, value);
      } else {
        dimensions.remove(dimensionId);
      }

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void dispatch(String instanceId, Promise promise) {
    try {
      Tracker tracker = trackers.get(instanceId);
      if (tracker != null) {
        tracker.dispatch();
        promise.resolve(null);
      } else {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void setDispatchInterval(String instanceId, int seconds, Promise promise) {
    try {
      Tracker tracker = trackers.get(instanceId);
      if (tracker != null) {
        tracker.setDispatchInterval(TimeUnit.SECONDS.toMillis(seconds));
        promise.resolve(null);
      } else {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void getDispatchInterval(String instanceId, Promise promise) {
    try {
      Tracker tracker = trackers.get(instanceId);
      if (tracker != null) {
        long intervalMillis = tracker.getDispatchInterval();
        int intervalSeconds = (int) TimeUnit.MILLISECONDS.toSeconds(intervalMillis);
        promise.resolve(intervalSeconds);
      } else {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void trackSiteSearch(String instanceId, String query, @Nullable String category, @Nullable Integer resultCount, Promise promise) {
    try {
      getTrackHelper(instanceId).search(query).category(category).count(resultCount).with(getTracker(instanceId));
      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void stop(String instanceId, Boolean dispatchRemaining, Promise promise) {
    try {
      Tracker tracker = trackers.get(instanceId);
      if (tracker != null) {
        if (dispatchRemaining) {
          tracker.dispatch();
        }
        
        trackers.remove(instanceId);
        customDimensionsMap.remove(instanceId);
        
        promise.resolve(null);
      } else {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void reset(String instanceId, Promise promise) {
    try {
      Tracker tracker = trackers.get(instanceId);
      if (tracker != null) {
        // Reset user ID
        tracker.setUserId(null);
        promise.resolve(null);
      } else {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void resetCustomDimensions(String instanceId, Promise promise) {
    try {
      Map<Integer, String> dimensions = customDimensionsMap.get(instanceId);
      if (dimensions != null) {
        dimensions.clear();
        promise.resolve(null);
      } else {
        promise.reject("not_initialized", "Matomo instance '" + instanceId + "' not initialized");
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  private Tracker getTracker(String instanceId) {
    Tracker tracker = trackers.get(instanceId);
    if (tracker == null) {
      throw new RuntimeException("Matomo instance '" + instanceId + "' must be initialized before usage");
    }
    return tracker;
  }

  private TrackHelper getTrackHelper(String instanceId) {
    Tracker tracker = getTracker(instanceId);
    Map<Integer, String> dimensions = customDimensionsMap.get(instanceId);
    
    TrackHelper trackHelper = TrackHelper.track();
    if (dimensions != null) {
      for (Map.Entry<Integer, String> entry : dimensions.entrySet()) {
        trackHelper = trackHelper.dimension(entry.getKey(), entry.getValue());
      }
    }
    return trackHelper;
  }

  private TrackMe onTrackCallback(String instanceId, TrackMe trackMe) {
    Map<Integer, String> dimensions = customDimensionsMap.get(instanceId);
    if (dimensions != null) {
      for (Map.Entry<Integer, String> dim : dimensions.entrySet()) {
        CustomDimension dimension = new CustomDimension(dim.getKey(), dim.getValue());
        CustomDimension.setDimension(trackMe, dimension);
      }
    }
    return trackMe;
  }
}
