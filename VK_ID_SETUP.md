# VK ID integration for iOS 13 — configuration status

This project is **not yet configured for live VK ID login**. An App ID and a valid callback method are needed. Do not enter real secrets into the repo.

## What we confirmed
- iOS target 13.0; test device iOS 13.6.
- The device can contact `https://api.vk.com/method/users.get?v=5.199`. It returns VK error 15, "token required", which is normal before login.
- The mobile VK website fails to load correctly on the test device, so WebKit-only login cannot be considered a tested solution.
- Current VK ID SDK 3.0.0 requires iOS 15+. Investigate / pin an older compatible SDK version such as 2.9.5 for this iOS 13 build.
- GitHub Pages under `https://giga-mox.github.io/vk-client-ios13/` is a **project path**. It cannot serve the AASA file at the domain root `https://giga-mox.github.io/.well-known/apple-app-site-association` from this project alone.
- An Apple AASA app identifier must include the **actual signing Team ID** plus the app's bundle identifier, currently `com.gigamox.vkclient13`.
- Unsigned IPA output has no Associated Domains entitlement. Sideload signing must support that entitlement and team identity. It is not enough to add an entry to Info.plist.

## Two viable paths

### 1. Register a VK ID iOS app with a Universal Link
You need **both** (a) a real domain root capable of hosting an AASA file and (b) compatible signing provisioning with Associated Domains.

If GitHub Pages is the only hosting provider, a special *user site repository* `Giga-mox/Giga-mox.github.io` could serve the file at the root of `giga-mox.github.io`, subject to hosting behavior and Apple's AASA validation requirements. This repo's GitHub integration cannot create that repository or enable Pages for you, so **none of that has been deployed**.

After the repo exists, enable Pages publishing from the root of `main`. Add a `.nojekyll` file and a `.well-known/apple-app-site-association` file (no extension), replacing TEAM_ID_HERE with the Team ID that signs the app:

```json
{
  "applinks": {
    "details": [
      {
        "appID": "TEAM_ID_HERE.com.gigamox.vkclient13",
        "paths": ["/vk_id_redirect", "/vk_id_redirect/*"]
      }
    ]
  }
}
```

Choose `https://giga-mox.github.io/vk_id_redirect` **only after** checking that the domain, AASA content-type, status 200, no redirects, and entitlements actually work with the final installed app. VK ID may require additional callback URL restrictions. The callback page itself must not record or transmit authorization codes.

### 2. Native-app redirect via a custom scheme (if VK ID supports it)
The historical VK iOS SDK used callback schemes like `vk<APP_ID>://`. Current VK ID registration may not accept this instead of a Universal Link; verify against the specific client type. Never assume a custom URL scheme will work merely because iOS supports schemes.

## Next data required (not secrets)
- VK ID app **public client ID** once an app is created.
- Whether the VK ID registration form accepts a custom scheme, or requires Universal Link.
- Which signing provider / entitlements are used to install IPA on iOS 13.

## Security
- Never add password, 2FA code, VK token, private signing key, or VK ID client secret to this public GitHub repository.
- Prefer authorization code + PKCE where supported; validate state and redirect.
- The app must not be presented as a working VK API client until auth, scopes and API endpoint access are verified on a device.

## Sources
- https://github.com/VKCOM/vkid-ios-sdk
- https://github.com/VKCOM/vkid-ios-sdk/blob/main/CHANGELOG.md
- https://developer.apple.com/documentation/technotes/tn3155-debugging-universal-links
