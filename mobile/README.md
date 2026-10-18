# Velma Bank Android app

See the [root README](../README.md) and [deployment guide](../docs/DEPLOYMENT.md).

```sh
flutter pub get
flutter run --flavor baseline
```

Choose the backend origin and lab CA via the connection icon. The app does not persist session tokens, keys, or connection settings. `baseline` is the main app; `clone` adds `.clone` to the package identity for side-by-side PoC comparison. No iOS target or RASP SDK is included.
