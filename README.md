<p align="center">
  <img src="https://github.com/taradepan/SnapCrop/raw/main/SnapCrop/Assets.xcassets/AppIcon.appiconset/SnapCrop%20128.png" alt="SnapCrop Logo" width="128" height="128"/>
</p>

# SnapCrop

SnapCrop is a lightweight, open source tool for capturing and editing screenshots, built entirely in Swift for **macOS**. Designed for speed and simplicity, SnapCrop lets you quickly capture and enhance screenshots with privacy in mind, everything runs locally, no data ever leaves your device.

## Features

- **Snap Screenshots**: Instantly capture the screen or a window using a simple interface.
- **Editing Tools**: Add gradients, effects, and quick adjustments to your screenshots.
- **Fast & Lightweight**: Small footprint, no third-party dependencies, and optimized for performance.
- **SwiftUI Interface**: Clean, modern UI powered by SwiftUI.
- **Privacy-first**: All processing happens locally, keeping your data safe.
- **Open Source & Free**: MIT licensed—use it, fork it, improve it!


## Screenshots
![image](https://github.com/user-attachments/assets/22271dc5-dd1c-4f17-a67a-07cb365a923e)

## Getting Started

### Prerequisites

- Xcode (latest recommended)
- macOS 

### Installation

Clone the repository and open the project in Xcode:

```sh
git clone https://github.com/taradepan/SnapCrop.git
cd SnapCrop
open SnapCrop.xcodeproj
```

Build and run on your preferred target (macOS).

## Usage

1. Launch SnapCrop.
2. Capture a screenshot, select an image, or drag-and-drop.
3. Apply gradients or effects as needed.
4. Copy or export your finished image.

## Project Structure

- `SnapCrop/` — Main app code (Swift/SwiftUI)
  - `AppDelegate.swift`, `SnapCropApp.swift` — App entry points
  - `ContentView.swift`, `EditingToolsView.swift`, `CaptureOptionsView.swift`, etc. — UI & logic
  - `ScreenshotCaptureEngine.swift` — Screenshot and image capture logic
  - `ScreenshotCanvasView.swift` — Image cropping and editing canvas
  - `Assets.xcassets` — App icons, images, etc.
- `SnapCropTests/` — Unit tests
- `SnapCropUITests/` — UI automation tests

## Contributing

We welcome contributions!

1. Fork the repo and create your feature branch:
2. Make your changes and add tests if appropriate.
3. Commit and push your branch.
4. Open a Pull Request explaining your changes with a video or a beautiful Screenshot.


## License

Distributed under the [MIT License](LICENSE).

---

Made with ❤️ by [taradepan](https://github.com/taradepan)
