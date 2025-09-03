/// Applies both button accessibility identifiers and root view identifiers.
/// This combines the functionality of UITestableButton and UITestableView.
@attached(body)
public macro UITestable() = #externalMacro(
    module: "UITestableMacros",
    type: "UITestableMacro"
)

/// Applies only button accessibility identifiers.
@attached(body)
public macro UITestableButton() = #externalMacro(
    module: "UITestableMacros",
    type: "UITestableButtonMacro"
)

/// Applies only root view identifiers.
@attached(body)
public macro UITestableView() = #externalMacro(
    module: "UITestableMacros",
    type: "UITestableViewMacro"
)
