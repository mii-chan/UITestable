# UITestable

UITestable is a Swift Macro package that automatically adds accessibility identifiers to SwiftUI views and buttons, making UI testing easier and more reliable.

## Features

UITestable provides three macros to help with different UI testing needs:

- `@UITestable`: Applies both button accessibility identifiers and root view identifiers
- `@UITestableButton`: Only applies accessibility identifiers to buttons
- `@UITestableView`: Only applies a root view identifier

## ⚠️ Important Usage Notes

### Function Body Macro Limitations

Swift's Function Body Macros currently cannot be applied directly to read-only computed properties like the `body` property in SwiftUI's `View` protocol.

Due to this limitation, you cannot apply the UITestable macros directly to the `body` property. As a workaround, you need to:

1. Create a separate function (e.g., `_body()`) with the UITestable macro
2. Call this function from your SwiftUI view's required `body` property implementation

This pattern is required for all UITestable macros.

### Development-Only Usage

It's recommended to wrap all UITestable macros in `#if DEBUG` conditions. This ensures that:

1. The accessibility identifiers are only added in development and test builds
2. The code has zero overhead in production builds
3. No unnecessary identifiers are exposed in release versions

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/mii-chan/UITestable.git", from: "0.1.0")
```

### Xcode

1. In Xcode, select **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/mii-chan/UITestable.git`
3. Select the version you want to use.

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
    var body: some View {
        _body()
    }

    #if DEBUG
    @UITestable
    #endif
    @ViewBuilder
    private func _body() -> some View {
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
private func _body() -> some View {
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
    var body: some View {
        _body()
    }

    #if DEBUG
    @UITestableButton
    #endif
    @ViewBuilder
    private func _body() -> some View {
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
private func _body() -> some View {
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
    var body: some View {
        _body()
    }

    #if DEBUG
    @UITestableView
    #endif
    @ViewBuilder
    private func _body() -> some View {
        VStack {
            Text("Profile")
            Image("avatar")
        }
    }
}
```

This will expand to:

```swift
private func _body() -> some View {
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

    var body: some View {
        _body()
    }

    #if DEBUG
    @UITestableView
    #endif
    @ViewBuilder
    private func _body() -> some View {
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
private func _body() -> some View {
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

- Swift 6.1+
- iOS 16.0+ / macOS 11.0+

## License

[MIT License](LICENSE.txt)
