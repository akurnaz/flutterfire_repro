# FlutterFire `demoProjectId` iOS Crash Reproduction

Minimal reproduction repository for the issue where calling `Firebase.initializeApp(demoProjectId: '...')` crashes on iOS with `SIGABRT` (`FIRInstallations validateAPIKey:`).

## Problem Description

When initializing Firebase using `demoProjectId` without a remote Firebase project or `GoogleService-Info.plist`:

```dart
await Firebase.initializeApp(
  demoProjectId: 'demo-template',
);
```

If the project includes any Firebase plugin that depends on `FirebaseInstallations` (such as `firebase_crashlytics`, `firebase_auth`, or `firebase_messaging`), the app crashes immediately on iOS startup with `EXC_CRASH (SIGABRT)` / `Abort trap: 6`.

## Stack Trace

```text
Termination: SIGNAL (Abort trap: 6 / SIGABRT)
CoreFoundation - __exceptionPreprocess
libobjc.A.dylib - objc_exception_throw
Runner - +[FIRInstallations validateAPIKey:]
Runner - +[FIRInstallations validateAppOptions:appName:]
Runner - -[FIRInstallations initWithAppOptions:appName:installationsIDController:prefetchAuthToken:]
Runner - -[FIRInstallations initWithApp:]
Runner - __40+[FIRInstallations componentsToRegister]_block_invoke
Runner - -[FIRComponentContainer instantiateInstanceForProtocol:withBlock:]
Runner - -[FIRComponentContainer instanceForProtocol:]
Runner - -[FIRComponentContainer instantiateEagerComponents]
Runner - +[FIRApp configureWithName:options:]
Runner - FLTFirebaseCorePlugin.initializeApp(appName:initializeAppRequest:completion:)
```

## Root Cause

1. In `firebase_core/lib/src/firebase.dart`, specifying `demoProjectId` generates mock options with `apiKey: '12345'`.
2. On iOS, native `FirebaseInstallations` (`FIRInstallations.m`) strictly validates:
   - `APIKey.length == 39` (`kExpectedAPIKeyLength = 39`)
   - `[APIKey substringToIndex:1] isEqualToString:@"A"`
3. Because `'12345'` fails this validation, an unhandled `NSException` is thrown, terminating the process with `SIGABRT`.

## Reproduction Steps

```bash
flutter pub get
flutter run
```
