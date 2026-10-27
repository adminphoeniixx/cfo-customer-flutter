# CFO Shop

CFO Shop is the customer storefront for browsing products, managing a cart, placing orders, tracking deliveries, and managing account details.

## Release build

Android release builds require a private signing keystore. Create `android/key.properties` from `android/key.properties.example`, then set the correct values. Never commit the real file or keystore.

```bash
flutter analyze
flutter build appbundle --release
```

The upload bundle is created at `build/app/outputs/bundle/release/app-release.aab`.

## Branding

The source artwork for the CFO Shop launcher icon is at `assets/branding/cfo_shop_launcher_icon.png`. Native Android and iOS launcher icon sizes are generated from it and already included.
