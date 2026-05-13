# UITestable

UITestable is a Swift Macro package that automatically adds accessibility identifiers to SwiftUI views and buttons, making UI testing easier and more reliable.

## Features

UITestable provides three macros to help with different UI testing needs:

- `@UITestable`: Applies both button accessibility identifiers and root view identifiers
- `@UITestableButton`: Only applies accessibility identifiers to buttons
- `@UITestableView`: Only applies a root view identifier

## Toolchain Requirement

> [!IMPORTANT]
> Attaching body macros to a computed property (such as `var body: some View`) currently requires a Swift toolchain from the `main-snapshot-2026-05-07` snapshot or later, selected in Xcode from Xcode > Toolchains. The requirement will go away once the support lands in a stable Swift release.

## Development-Only Usage

It's recommended to wrap UITestable macros in `#if DEBUG` so that accessibility identifiers are only emitted in development and test builds, and aren't exposed in release versions.

## Installation

> [!IMPORTANT]
> UITestable currently pins `swift-syntax` to a specific revision (to pull in the fix that allows body macros on computed properties), so SwiftPM treats UITestable as an unstable-version package. As a result, adding UITestable with a version-based requirement (e.g. `from: "0.2.0"`) will fail with an error such as:
>
> ```
> 'uitestable' is required using a stable-version but 'uitestable' depends on an unstable-version package 'swift-syntax'.
> ```
>
> Until `swift-syntax` ships a tagged release containing that fix, please add UITestable using a **branch** or **commit (revision)** requirement as shown below.

### Swift Package Manager

Add the following dependency to your `Package.swift` file (use `branch:` or `revision:`, not `from:`):

```swift
// Track the latest main
.package(url: "https://github.com/mii-chan/UITestable.git", branch: "main")

// Or pin to a specific commit
.package(url: "https://github.com/mii-chan/UITestable.git", revision: "01f7396f730b1671971756a432e8f03c8ce7ac60")
```

### Xcode

1. In Xcode, select **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/mii-chan/UITestable.git`
3. Open the **Dependency Rule** dropdown and choose either:
   - **Branch** and enter `main`, or
   - **Commit** and enter a full commit SHA.
4. Click **Add Package**.

Selecting a version-based rule will fail with the error shown above.

## Usage

Import the package in your SwiftUI files. It's recommended to wrap the import and macro usage in `#if DEBUG` conditions to ensure they only run in development:

```swift
import SwiftUI
#if DEBUG
import UITestable
#endif
```

### Combined Functionality (`@UITestable`)

Use the `@UITestable` macro to automatically add accessibility identifiers to both buttons and the root view:

```swift
struct ContentView: View {
    #if DEBUG
    @UITestable
    #endif
    var body: some View {
        VStack {
            Button("Login") {
                print("Login tapped")
            }

            Button("Register") {
                print("Register tapped")
            }
        }
    }
}
```

This will expand to code similar to:

```swift
var body: some View {
    VStack {
        Button("Login") {
            print("Login tapped")
        }
        .accessibilityIdentifier("ContentView_Login")

        Button("Register") {
            print("Register tapped")
        }
        .accessibilityIdentifier("ContentView_Register")
    }
    .background(
        Color.clear
            .accessibilityIdentifier("ContentView")
    )
}
```

### Button-Only Functionality (`@UITestableButton`)

Use the `@UITestableButton` macro when you only want to add accessibility identifiers to buttons:

```swift
struct LoginView: View {
    #if DEBUG
    @UITestableButton
    #endif
    var body: some View {
        VStack {
            Button("Login") {
                print("Login tapped")
            }
        }
    }
}
```

This will expand to:

```swift
var body: some View {
    VStack {
        Button("Login") {
            print("Login tapped")
        }
        .accessibilityIdentifier("LoginView_Login")
    }
}
```

### RootView-Only Functionality (`@UITestableView`)

Use the `@UITestableView` macro when you only want to add an accessibility identifier to the root view:

```swift
struct ProfileView: View {
    #if DEBUG
    @UITestableView
    #endif
    var body: some View {
        VStack {
            Text("Profile")
            Image("avatar")
        }
    }
}
```

This will expand to:

```swift
var body: some View {
    VStack {
        Text("Profile")
        Image("avatar")
    }
    .background(
        Color.clear
            .accessibilityIdentifier("ProfileView")
    )
}
```

### Control Flow with `@UITestableView`

When using conditional statements or other control flow structures, the macro automatically wraps the content in a `Group` to ensure the accessibility identifier is applied correctly:

```swift
struct SettingsView: View {
    var showAdvancedSettings: Bool = false

    #if DEBUG
    @UITestableView
    #endif
    var body: some View {
        if showAdvancedSettings {
            VStack {
                Text("Advanced Settings")
            }
        } else {
            VStack {
                Text("Basic Settings")
            }
        }
    }
}
```

This will expand to:

```swift
var body: some View {
    Group {
        if showAdvancedSettings {
            VStack {
                Text("Advanced Settings")
            }
        } else {
            VStack {
                Text("Basic Settings")
            }
        }
    }
    .background(
        Color.clear
            .accessibilityIdentifier("SettingsView")
    )
}
```

## UI Testing

Once you've added the macros, you can easily access elements in UI tests:

```swift
import XCTest

class MyAppUITests: XCTestCase {
    func testLogin() {
        let app = XCUIApplication()
        app.launch()

        // Access the button using its generated identifier
        app.buttons["ContentView_Login"].tap()

        // Access the view using its generated identifier
        XCTAssertTrue(app.otherElements["ProfileView"].exists)
    }
}
```

## How It Works

The macro uses Swift's macro system to transform the view body at compile time. It:

1. For buttons: Adds `.accessibilityIdentifier()` modifiers with generated IDs based on the struct name and button label
2. For views: Wraps the root view with a background `.accessibilityIdentifier()` that doesn't affect visual appearance
3. For conditional views: Automatically wraps statements in a `Group` before applying the identifier

## Requirements

- Swift toolchain `main-snapshot-2026-05-07` or later (selected via Xcode > Toolchains)
- iOS 16.0+ / macOS 11.0+

## License

[MIT License](LICENSE.txt)
