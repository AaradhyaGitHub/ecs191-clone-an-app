# Developer environment

## Machine
- macOS Sequoia 15.2, Apple Silicon (arm64)
- Disk: ~26 GB free of 228 GB (tight; clear `~/Library/Developer/Xcode/DerivedData` if builds fail for space)

## Toolchain
- Xcode 16.3 (build 16E140), ships Swift 6.1
- Standalone Command Line Tools also installed (Swift 6.0.3)
- iOS 18.4 Simulator: iPhone 16, 16 Pro, 16e, and others
- A starter SwiftUI app (`HelloSwift/`) built successfully, so the toolchain works.

## Known issue
`xcode-select` points at the Command Line Tools, so `xcodebuild` fails from the terminal. Fix:
```
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## Grader's toolchain vs. ours
- The assignment requires the app to build with **Xcode 27**.
- Xcode 27 (released Sept 14, 2026) requires macOS Tahoe 26.6 or later, so it can't run on this Mac without a major macOS upgrade. Not upgrading before the deadline.
- Mitigation: deployment target iOS 17, no iOS 26+ APIs, no third-party dependencies, plain Xcode project. README states the tested toolchain. Developer is asking the professor whether this is acceptable.
