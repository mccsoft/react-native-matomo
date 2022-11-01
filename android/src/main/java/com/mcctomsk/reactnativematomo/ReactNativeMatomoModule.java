package com.mcctomsk.reactnativematomo;

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

@ReactModule(name = ReactNativeMatomoModule.NAME)
public class ReactNativeMatomoModule extends ReactContextBaseJavaModule {
  private Tracker tracker;
  /**
   * These custom dimensions will get added to every tracking event. This
   * is how Matomo iOS SDK works.
   */
  private Map<Integer, String> mCustomDimensions = new HashMap<>();

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
  public void initialize(String apiUrl, int siteId, Promise promise) {
    try {
      if (tracker == null) {
        tracker = TrackerBuilder
          .createDefault(apiUrl, siteId)
          .build(Matomo.getInstance(getReactApplicationContext()));

        Tracker.Callback callback = ReactNativeMatomoModule.this::onTrackCallback;
        tracker.addTrackingCallback(callback);
      }

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void isInitialized(Promise promise) {
    try {
      promise.resolve(tracker == null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void trackView(String route, @Nullable String title, Promise promise) {
    try {
      String actualTitle = title == null ? route : title;
      getTrackHelper().screen(route).title(actualTitle).with(tracker);

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void trackEvent(String category, String action, ReadableMap optionalParameters, Promise promise) {
    try {
      TrackHelper.EventBuilder event = getTrackHelper().event(category, action);
      if (optionalParameters.hasKey("name")) {
        event.name(optionalParameters.getString("name"));
      }
      if (optionalParameters.hasKey("value")) {
        event.value((float) optionalParameters.getDouble("value"));
      }

      event.with(tracker);

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void trackGoal(int goalId, ReadableMap values) {
    Float revenue = null;
    if (values.hasKey("revenue") && !values.isNull("revenue")) {
      revenue = (float) values.getDouble("revenue");
    }

    getTrackHelper().goal(goalId).revenue(revenue).with(tracker);
  }

  @ReactMethod
  public void trackAppDownload() {
    getTrackHelper().download().with(tracker);
  }

  @ReactMethod
  public void setAppOptOut(Boolean isOptedOut, Promise promise) {
    try {
      tracker.setOptOut(isOptedOut);

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void setUserId(String userId, Promise promise) {
    try {
      tracker.setUserId(userId);
      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void setCustomDimension(int dimensionId, @Nullable String value, Promise promise) {
    try {
      if (value != null && value.length() > 0) {
        mCustomDimensions.put(dimensionId, value);
      } else {
        mCustomDimensions.remove(dimensionId);
      }

      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  private TrackHelper getTrackHelper() {
    if (tracker == null) {
      throw new RuntimeException("Tracker must be initialized before usage");
    }
    TrackHelper trackHelper = TrackHelper.track();
    for (Map.Entry<Integer, String> entry : mCustomDimensions.entrySet()) {
      trackHelper = trackHelper.dimension(entry.getKey(), entry.getValue());
    }
    return trackHelper;
  }

  private TrackMe onTrackCallback(TrackMe trackMe) {
    for (Map.Entry<Integer, String> dim : mCustomDimensions.entrySet()) {
      CustomDimension dimension = new CustomDimension(dim.getKey(), dim.getValue());
      CustomDimension.setDimension(trackMe, dimension);
    }

    return trackMe;
  }
}
