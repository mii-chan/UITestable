import SwiftSyntax

final class ButtonModifierRewriter: SyntaxRewriter {
    private let typeHierarchyPrefix: String

    init(typeHierarchyPrefix: String) {
        self.typeHierarchyPrefix = typeHierarchyPrefix
    }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        guard let buttonCall = findButtonCall(node) else {
            return super.visit(node)
        }

        // Skip if in the middle of a modifier chain
        if let parent = node.parent,
           parent.is(MemberAccessExprSyntax.self) {
            return super.visit(node)
        }

        if MacroHelper.hasAccessibilityIdentifier(node) {
            return super.visit(node)
        }

        guard let label = extractButtonLabel(from: buttonCall) else {
            return super.visit(node)
        }

        let newlineIndent = Trivia.newlines(1) + Trivia.spaces(node.leadingTrivia.spaceCount() ?? 0)
        let newExpr = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: ExprSyntax(node),
                period: .periodToken(leadingTrivia: newlineIndent),
                name: .identifier("accessibilityIdentifier")
            ),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(
                    expression: ExprSyntax(StringLiteralExprSyntax(content: "\(typeHierarchyPrefix)_\(label)"))
                )
            },
            rightParen: .rightParenToken()
        )

        return ExprSyntax(super.visit(newExpr))
    }

    private func findButtonCall(_ expr: FunctionCallExprSyntax) -> FunctionCallExprSyntax? {
        if MacroHelper.unwrapCalledIdentifier(from: expr) == "Button" {
            return expr
        }

        if let member = expr.calledExpression.as(MemberAccessExprSyntax.self),
           let baseCall = member.base?.as(FunctionCallExprSyntax.self) {
            return findButtonCall(baseCall)
        }

        return nil
    }

    private func extractButtonLabel(from buttonCall: FunctionCallExprSyntax) -> String? {
        guard let firstArg = buttonCall.arguments.first,
              firstArg.label == nil,
              let str = firstArg.expression.as(StringLiteralExprSyntax.self),
              let firstSegment = str.segments.first,
              let stringSegment = firstSegment.as(StringSegmentSyntax.self) else {
            return nil
        }

        return stringSegment.content.text
    }
}
