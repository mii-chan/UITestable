import SwiftSyntax

enum MacroHelper {
    /// Determines if an expression already has an accessibilityIdentifier modifier.
    ///
    /// This function recursively examines an expression to determine whether it includes an
    /// accessibilityIdentifier modifier within its function call chain.
    ///
    /// - Parameter expr: The expression to analyze
    /// - Returns: Boolean indicating whether the expression has an accessibilityIdentifier
    static func hasAccessibilityIdentifier(_ expr: some ExprSyntaxProtocol) -> Bool {
        if let functionCall = expr.as(FunctionCallExprSyntax.self),
           let calledExpr = functionCall.calledExpression.as(MemberAccessExprSyntax.self) {

            if calledExpr.declName.baseName.text == "accessibilityIdentifier" {
                return true
            }

            if let base = calledExpr.base {
                return hasAccessibilityIdentifier(base)
            }
        }

        return false
    }

    /// Extracts the base identifier name from a function call expression.
    ///
    /// This function attempts to retrieve the base identifier of a function call by:
    /// 1. Checking if the called expression is a direct declaration reference, or
    /// 2. Checking if it's a member access expression and extracting from its base
    ///
    /// - Parameter call: The function call expression to analyze
    /// - Returns: The base identifier name as String if found, nil otherwise
    static func unwrapCalledIdentifier(from call: FunctionCallExprSyntax) -> String? {
        if let decl = call.calledExpression.as(DeclReferenceExprSyntax.self) {
            return decl.baseName.text
        }

        if let member = call.calledExpression.as(MemberAccessExprSyntax.self),
           let baseCall = member.base?.as(DeclReferenceExprSyntax.self) {
            return baseCall.baseName.text
        }
        return nil
    }
}
