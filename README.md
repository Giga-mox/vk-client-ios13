# VK Client iOS 13 — Native prototype v0.2

Native Swift/UIKit prototype for iOS 13.0+, targeted at iPhone 6s Plus (iOS 13.6).

## What works in the current source
- Native UIKit home screen, **no WKWebView dependency**.
- Direct HTTPS connectivity test with `URLSession` against the official VK API.
- Correct distinction between VK API error 15 (connection succeeds, token required) and network failure.
- Friendly diagnostic and retry.

## What does NOT work yet
- **No login, messages, feed, profile or other authenticated VK features.** The login button explains the current requirements; it does not impersonate a working login flow.
- No VK ID client ID has been configured and no account token is collected.
- The installed IPA with `ldid` is not guaranteed to have working Apple Associated Domains / Universal Links.
- GitHub Pages landing page is NOT a complete OAuth callback implementation.

## Build an unsigned IPA
1. Open [Actions](https://github.com/Giga-mox/vk-client-ios13/actions).
2. Open **Build iOS 13 IPA**.
3. Run workflow or inspect the latest push.
4. After a **successful** build, download the `VKClient-iOS13-unsigned` artifact.
5. Extract the ZIP, sign and install `VKClient-iOS13-unsigned.ipa` using your existing jailbreak IPA Signer.

The workflow's success and on-device compatibility still need to be verified.

## Authentication path
VK ID SDK 2.9.5 predates SDK 3.0.0 (which raised minimum iOS to 15); SDK 2.x uses Swift 5.9 and Xcode 15+. Before integration, register a valid client, confirm redirect requirements and test whether WebView-only authorization in the older SDK can complete under iOS 13 WebKit. Never post a client secret, VK access token, password, or signing certificate to a public repo.

Read [VK_ID_SETUP.md](VK_ID_SETUP.md).

Not affiliated with VK.
