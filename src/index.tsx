import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package '@mccsoft/react-native-matomo' doesn't seem to be linked. Make sure: \n\n` +
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

/** Default instance ID used for backward compatibility */
const DEFAULT_INSTANCE_ID = 'default';

/**
 * Normalize URL by removing trailing slash
 */
function normalizeUrl(url: string): string {
  return url.endsWith('/') ? url.slice(0, -1) : url;
}

/**
 * Options for initializing a Matomo instance
 */
export interface MatomoInitOptions {
  /** The Matomo server URL (e.g., https://your-matomo.com/matomo.php) */
  apiUrl: string;
  /** The site ID configured in Matomo */
  siteId: number;
  /** Whether to use a cached queue for offline support (iOS only, Android always uses cached queue) */
  cachedQueue?: boolean;
}

/**
 * Options for stopping a Matomo instance
 */
export interface MatomoStopOptions {
  /** Whether to force dispatch remaining events before stopping */
  dispatchRemaining?: boolean;
}

/**
 * Matomo tracker class that supports multiple instances
 */
export class MatomoTracker {
  private readonly instanceId: string;

  /**
   * Create a new Matomo tracker instance
   * @param instanceId Unique identifier for this tracker instance. Defaults to 'default' for backward compatibility.
   */
  constructor(instanceId: string = DEFAULT_INSTANCE_ID) {
    this.instanceId = instanceId;
  }

  /**
   * Get the instance ID
   */
  getInstanceId(): string {
    return this.instanceId;
  }

  /**
   * Initialize the Matomo tracker
   * @param apiUrl The Matomo server URL
   * @param siteId The site ID
   * @param cachedQueue Whether to use cached queue (iOS only)
   */
  async initialize(
    apiUrl: string,
    siteId: number,
    cachedQueue?: boolean
  ): Promise<void> {
    const normalizedUrl = normalizeUrl(apiUrl);
    // Only pass cachedQueue on iOS - Android SDK always uses cached queue
    if (Platform.OS === 'ios') {
      return ReactNativeMatomo.initialize(
        this.instanceId,
        normalizedUrl,
        siteId,
        !!cachedQueue
      );
    }
    return ReactNativeMatomo.initialize(
      this.instanceId,
      normalizedUrl,
      siteId
    );
  }

  /**
   * Initialize the Matomo tracker with options object
   * @param options Initialization options
   */
  async initializeWithOptions(options: MatomoInitOptions): Promise<void> {
    return this.initialize(options.apiUrl, options.siteId, options.cachedQueue);
  }

  /**
   * Check if this tracker instance is initialized
   */
  async isInitialized(): Promise<boolean> {
    return ReactNativeMatomo.isInitialized(this.instanceId);
  }

  /**
   * Track a screen view
   * @param route The screen path/route
   * @param title Optional screen title
   */
  async trackView(route: string, title?: string): Promise<void> {
    return ReactNativeMatomo.trackView(this.instanceId, route, title);
  }

  /**
   * Track an event
   * @param category Event category
   * @param action Event action
   * @param name Optional event name
   * @param value Optional numeric value
   * @param url Optional URL
   */
  async trackEvent(
    category: string,
    action: string,
    name?: string,
    value?: number,
    url?: string
  ): Promise<void> {
    return ReactNativeMatomo.trackEvent(this.instanceId, category, action, {
      name,
      value,
      url,
    });
  }

  /**
   * Track a goal conversion
   * @param goalId The goal ID
   * @param revenue Optional revenue value
   */
  async trackGoal(goalId: number, revenue?: number): Promise<void> {
    return ReactNativeMatomo.trackGoal(this.instanceId, goalId, { revenue });
  }

  /**
   * Track app download (Android only)
   */
  async trackAppDownload(): Promise<void> {
    return ReactNativeMatomo.trackAppDownload(this.instanceId);
  }

  /**
   * Set a custom dimension
   * @param id The dimension ID
   * @param value The dimension value, or null to remove
   */
  async setCustomDimension(id: number, value: string | null): Promise<void> {
    return ReactNativeMatomo.setCustomDimension(this.instanceId, id, value);
  }

  /**
   * Set the user ID
   * @param userId The user ID, or null to clear
   */
  async setUserId(userId: string | null): Promise<void> {
    return ReactNativeMatomo.setUserId(this.instanceId, userId);
  }

  /**
   * Set the app opt-out status
   * @param isOptedOut Whether the app should opt out of tracking
   */
  async setAppOptOut(isOptedOut: boolean): Promise<void> {
    return ReactNativeMatomo.setAppOptOut(this.instanceId, isOptedOut);
  }

  /**
   * Get the current app opt-out status
   * @returns Whether the app is currently opted out of tracking
   */
  async isOptOut(): Promise<boolean> {
    return ReactNativeMatomo.isOptOut(this.instanceId);
  }

  /**
   * Manually dispatch queued events
   */
  async dispatch(): Promise<void> {
    return ReactNativeMatomo.dispatch(this.instanceId);
  }

  /**
   * Set the automatic dispatch interval
   * @param seconds Interval in seconds (must be positive)
   */
  async setDispatchInterval(seconds: number): Promise<void> {
    if (typeof seconds !== 'number' || seconds <= 0) {
      throw new Error(
        'Invalid interval. The value must be a positive number.'
      );
    }
    return ReactNativeMatomo.setDispatchInterval(this.instanceId, seconds);
  }

  /**
   * Get the current dispatch interval
   * @returns Interval in seconds
   */
  async getDispatchInterval(): Promise<number> {
    return ReactNativeMatomo.getDispatchInterval(this.instanceId);
  }

  /**
   * Track a site search
   * @param query The search query
   * @param category Optional search category
   * @param resultCount Optional result count
   */
  async trackSiteSearch(
    query: string,
    category?: string,
    resultCount?: number
  ): Promise<void> {
    return ReactNativeMatomo.trackSiteSearch(
      this.instanceId,
      query,
      category,
      resultCount
    );
  }

  /**
   * Stop and remove this tracker instance
   * @param options Options for stopping
   */
  async stop(options?: MatomoStopOptions): Promise<void> {
    return ReactNativeMatomo.stop(
      this.instanceId,
      options?.dispatchRemaining ?? false
    );
  }

  /**
   * Reset the user ID (generates a new visitor ID)
   */
  async reset(): Promise<void> {
    return ReactNativeMatomo.reset(this.instanceId);
  }

  /**
   * Reset custom dimensions
   */
  async resetCustomDimensions(): Promise<void> {
    return ReactNativeMatomo.resetCustomDimensions(this.instanceId);
  }

  /**
   * Get the current user ID
   * @returns The user ID or null if not set
   */
  async getUserId(): Promise<string | null> {
    return ReactNativeMatomo.getUserId(this.instanceId);
  }

  /**
   * Start a new session for the next tracking event
   */
  async startNewSession(): Promise<void> {
    return ReactNativeMatomo.startNewSession(this.instanceId);
  }
}

// ============================================================================
// LEGACY API - Backward compatible functions using default instance
// ============================================================================

/** Default tracker instance for backward compatibility */
const defaultTracker = new MatomoTracker(DEFAULT_INSTANCE_ID);

/**
 * Initialize the default Matomo tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function initialize(
  apiUrl: string,
  siteId: number,
  cachedQueue?: boolean
): Promise<void> {
  return defaultTracker.initialize(apiUrl, siteId, cachedQueue);
}

/**
 * Check if the default tracker is initialized
 * @deprecated Use MatomoTracker class for new implementations
 */
export function isInitialized(): Promise<boolean> {
  return defaultTracker.isInitialized();
}

/**
 * Track a screen view with the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function trackView(route: string, title?: string): Promise<void> {
  return defaultTracker.trackView(route, title);
}

/**
 * Track an event with the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function trackEvent(
  category: string,
  event: string,
  name?: string,
  value?: number,
  url?: string
): Promise<void> {
  return defaultTracker.trackEvent(category, event, name, value, url);
}

/**
 * Track a goal with the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function trackGoal(goalId: number, revenue?: number): Promise<void> {
  return defaultTracker.trackGoal(goalId, revenue);
}

/**
 * Track app download with the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function trackAppDownload(): Promise<void> {
  return defaultTracker.trackAppDownload();
}

/**
 * Set a custom dimension on the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function setCustomDimension(
  id: number,
  value: string | null
): Promise<void> {
  return defaultTracker.setCustomDimension(id, value);
}

/**
 * Set user ID on the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function setUserId(userId: string | null): Promise<void> {
  return defaultTracker.setUserId(userId);
}

/**
 * Set app opt-out on the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function setAppOptOut(isOptedOut: boolean): Promise<void> {
  return defaultTracker.setAppOptOut(isOptedOut);
}

/**
 * Dispatch events on the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function dispatch(): Promise<void> {
  return defaultTracker.dispatch();
}

/**
 * Set dispatch interval on the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function setDispatchInterval(seconds: number): Promise<void> {
  return defaultTracker.setDispatchInterval(seconds);
}

/**
 * Get dispatch interval on the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function getDispatchInterval(): Promise<number> {
  return defaultTracker.getDispatchInterval();
}

/**
 * Track site search with the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function trackSiteSearch(
  query: string,
  category?: string,
  resultCount?: number
): Promise<void> {
  return defaultTracker.trackSiteSearch(query, category, resultCount);
}

/**
 * Reset the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function reset(): Promise<void> {
  return defaultTracker.reset();
}

/**
 * Reset custom dimensions on the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function resetCustomDimensions(): Promise<void> {
  return defaultTracker.resetCustomDimensions();
}

/**
 * Stop the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function stop(options?: MatomoStopOptions): Promise<void> {
  return defaultTracker.stop(options);
}

/**
 * Get user ID from the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function getUserId(): Promise<string | null> {
  return defaultTracker.getUserId();
}

/**
 * Start a new session on the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function startNewSession(): Promise<void> {
  return defaultTracker.startNewSession();
}

/**
 * Get app opt-out status from the default tracker
 * @deprecated Use MatomoTracker class for new implementations
 */
export function isOptOut(): Promise<boolean> {
  return defaultTracker.isOptOut();
}

// Export the class
export { MatomoTracker as Matomo };

// Default export for backward compatibility
export default {
  // Class export
  MatomoTracker,
  Matomo: MatomoTracker,

  // Legacy functions for backward compatibility
  initialize,
  isInitialized,
  trackView,
  trackEvent,
  trackGoal,
  trackAppDownload,
  setCustomDimension,
  setUserId,
  setAppOptOut,
  dispatch,
  setDispatchInterval,
  getDispatchInterval,
  trackSiteSearch,
  reset,
  resetCustomDimensions,
  stop,
  getUserId,
  startNewSession,
  isOptOut,
};
