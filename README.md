# VK Client for iOS 13

Experimental VK client for iOS 13.0+ (UIKit + WKWebView).

## Version 0.1
- Opens the official VK mobile website, `https://m.vk.com/`.
- VK ID login is handled by the website. No password is sent to an independent server.
- Persistent WKWebView cookies/session stored on-device.
- Back / forward / home / refresh / system share controls.
- Supports VK links that open in a new window.
- iOS 13 compatible and built with Swift 5 / UIKit.
- No app ID or developer token required for this web-based version.

**Limitations:** This is a web-based MVP, not a fully native VK API implementation. Login, video, media upload and other features have not yet been tested on an actual iOS 13 device; some website or VK ID functionality can be limited by the legacy WebKit engine. Push notifications are not implemented.

## Build on GitHub
1. Open the **Actions** tab.
2. Select **Build iOS 13 IPA** and click **Run workflow**, or let a push to main trigger a build.
3. Open the finished run and download the `VKClient-iOS13-unsigned` artifact.
4. Extract the ZIP archive to get `VKClient-iOS13-unsigned.ipa`.
5. Sign and install the IPA with your own sideloading workflow. This build is **unsigned**.

## Local build (Mac)
Install Xcode and XcodeGen. Run:
```sh
xcodegen generate
xcodebuild -project VKClient.xcodeproj -scheme VKClient -configuration Release -sdk iphoneos CODE_SIGNING_ALLOWED=NO build
```

## Security
Never enter VK credentials into GitHub Actions or the repository. This app embeds the official VK pages and persists the web session locally. Source code is provided for inspection. Not affiliated with VK.

## Roadmap
- Validate the iOS 13.6 login flow and mobile site features on hardware.
- Add optional native screens with VK ID authorization and officially supported VK API methods.
- Better error handling, in-app navigation and media management.
