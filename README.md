# 🚀 Simple Github Users Client with Persistence (iOS)

## Notes:

- The project uses Carthage for dependency management. 
   - UPDATED 2021-05-28: Carthage binaries now included with project for quick builds. 
   Should prevent `No Such Module` errors when `carthage update` 
   is not executed prior)
   - UPDATED 2021-06-09: For compatibility with Xcode 12.3+, .framework files have been
   converted into platform-independent .xcframework files
- Scroll to top implemented by tapping on navbar title icon
- Debug flags can be activated in AppConfig.plist, including visual reloading of table cell data
- Image color inversion routine may slow down list rendering but can be disabled
through `DBG_DISABLE_IMAGE_INVERT` in AppConfig.plist (may need a refresh due to image caching)
- App uses `DispatchSemaphore`s to ensure that only one network call  is performed at a time for 
each server source. This means that image loading happens sequentially and synchronously, and is 
by nature slower than when performed asynchronously. Verbosity to indicate which
image is downloading at the moment can be displayed by enabling verbose network calls in AppConfig.plist 
(`DBG_VERBOSE_NETWORK_CALLS`).

## Misc
- Exponential backoff used for reloading stale data when HTTP server failure occurs to avoid pommeling the backend. Transport errors are handled by periodic async connectivity timer.
- Private background MOC for write queries, viewContext for read queries
- Uses `performAndWait` with private MOC to synchronize on writing
- VFL and layout anchor constraints for home (code), storyboard for profile
- Profile view uses shimmer
