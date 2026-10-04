# SafariFind

Long-press the **Share** button in Safari to open **Find on Page**.

On iPhone, Safari hides "Find on Page" inside the share sheet, so you have to tap Share and then scroll to find it. SafariFind gives you a shortcut. A normal tap on Share still opens the share sheet, and a long-press (0.3s) opens the find bar.

## Why this repo exists

SafariFind was originally made by [P2KDev](https://github.com/p2kdev). The developer later deleted the GitHub repository, so the source code was lost and only the compiled `.deb` (v1.1.2, rootless) was left.

This repo is an **independent reimplementation**, not P2KDev's original code:

1. The behaviour was worked out by inspecting the 1.1.2 binary: which classes and methods it hooks, and what it calls.
2. The tweak was then rewritten from scratch in Logos.
3. It was updated to work on **iOS 17**. In 1.1.2, the gesture was attached in `-[BrowserRootViewController viewDidLoad]`. On iOS 17 the share button's view doesn't exist yet at that point, so the long-press never worked.

All credit for the original idea goes to P2KDev.

## Compatibility

- iOS 15 – 17
- **roothide** (default build) and **rootless**
- Injected into Safari only (`com.apple.mobilesafari`)

## Install

Prebuilt packages are in [`packages/`](packages):

| Jailbreak | Package |
|---|---|
| roothide | `com.p2kdev.safarifind_1.1.4_iphoneos-arm64e.deb` |
| rootless | `com.p2kdev.safarifind_1.1.4_iphoneos-arm64.deb` |

Install with Sileo, Filza or `dpkg -i`, then kill Safari from the app switcher (or respring).

The package keeps the original identifier `com.p2kdev.safarifind`, so it upgrades over an existing 1.1.2 install.

## How it works

- **`-[_UIButtonBarButton layoutSubviews]`** — when the button shows the `square.and.arrow.up` symbol, a `UILongPressGestureRecognizer` (0.3s) is attached to it once.
- **`-[_UIButtonBarButton setHighlighted:]`** — on iOS 15+ the Share button has its own long-press context menu. This hook disables it on that button so it doesn't take over the gesture.
- **On long-press**, the tweak walks the responder chain up to `BrowserRootViewController` and calls `-[BrowserController find:]` on iOS 16+, or `-findKeyPressed` on iOS 15.

## Build

Requires [Theos](https://theos.dev). For roothide builds, use the [roothide fork](https://github.com/roothide/theos).

```bash
# roothide (default)
make package FINALPACKAGE=1

# rootless
make clean
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
```

A build without `FINALPACKAGE=1` is a debug build. It logs each step with the `[SafariFind]` prefix, which you can read in Console.app.

Theos does not support project paths that contain spaces.

## License

[MIT](LICENSE). The license covers the code in this repository. It does not cover P2KDev's original 1.1.2 binary.
