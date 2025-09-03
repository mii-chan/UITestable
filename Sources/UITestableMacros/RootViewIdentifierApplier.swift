import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

struct RootViewIdentifierApplier {
    let typeHierarchyPrefix: String

    func apply(to body: CodeBlockItemListSyntax) -> CodeBlockItemListSyntax {
        guard let firstItem = body.first else {
            return body
        }

        if let functionCallExpr = firstItem.item.as(FunctionCallExprSyntax.self) {
            if MacroHelper.hasAccessibilityIdentifier(functionCallExpr) {
                return body
            }

            let modifiedExpr = addBackgroundModifier(to: functionCallExpr)

            let newItem = CodeBlockItemSyntax(
                item: .expr(modifiedExpr)
            )

            return CodeBlockItemListSyntax([newItem])
        } else if let exprStmt = firstItem.item.as(ExpressionStmtSyntax.self) {
            if MacroHelper.hasAccessibilityIdentifier(exprStmt.expression) {
                return body
            }

            let wrappedExpr = wrapInGroup(exprStmt.expression)
            let modifiedExpr = addBackgroundModifier(to: wrappedExpr)

            let newItem = CodeBlockItemSyntax(
                item: .expr(modifiedExpr)
            )

            return CodeBlockItemListSyntax([newItem])
        } else if let returnStmt = firstItem.item.as(ReturnStmtSyntax.self),
                let returnExpr = returnStmt.expression {
            if MacroHelper.hasAccessibilityIdentifier(returnExpr) {
                return body
            }

            let modifiedExpr: ExprSyntax

            if returnExpr.is(FunctionCallExprSyntax.self) {
                modifiedExpr = addBackgroundModifier(to: returnExpr)
            } else {
                let wrappedExpr = wrapInGroup(returnExpr)
                modifiedExpr = addBackgroundModifier(to: wrappedExpr)
            }

            let newReturnStmt = ReturnStmtSyntax(
                returnKeyword: returnStmt.returnKeyword,
                expression: modifiedExpr
            )

            let newItem = CodeBlockItemSyntax(
                item: .stmt(StmtSyntax(newReturnStmt))
            )

            return CodeBlockItemListSyntax([newItem])
        }

        return body
    }

    // Helper method to add background with accessibility modifiers to an expression with a line break
    private func addBackgroundModifier(to expr: some ExprSyntaxProtocol) -> ExprSyntax {
        let newlineIndent = Trivia.newlines(1) + Trivia.spaces(expr.leadingTrivia.spaceCount() ?? 0)
        let baseIndent = expr.leadingTrivia.spaceCount() ?? 0

        let memberAccess = MemberAccessExprSyntax(
            base: expr,
            period: .periodToken(leadingTrivia: newlineIndent),
            name: TokenSyntax.identifier("background")
        )

        let modifiedColorClear = ExprSyntax(
            createNestedModifiersExpr(baseIndent: baseIndent)
        )

        // Create the function call for background(...)
        let backgroundCall = FunctionCallExprSyntax(
            calledExpression: memberAccess,
            leftParen: TokenSyntax.leftParenToken(trailingTrivia: .newline + .spaces(baseIndent + 4)),
            arguments: LabeledExprListSyntax([
                LabeledExprSyntax(
                    expression: modifiedColorClear
                )
            ]),
            rightParen: TokenSyntax.rightParenToken(leadingTrivia: .newline + .spaces(baseIndent))
        )

        return ExprSyntax(backgroundCall)
    }

    // Helper method to create Color.clear with accessibility modifiers
    private func createNestedModifiersExpr(baseIndent: Int = 0) -> ExprSyntax {
        // Start with Color.clear
        let colorClear = DeclReferenceExprSyntax(
            baseName: TokenSyntax.identifier("Color.clear")
        )

        // Add .accessibilityIdentifier modifier
        let withIdentifier = MemberAccessExprSyntax(
            base: ExprSyntax(colorClear),
            period: .periodToken(leadingTrivia: .newline + .spaces(baseIndent + 8)),
            name: TokenSyntax.identifier("accessibilityIdentifier")
        )

        let withIdentifierCall = FunctionCallExprSyntax(
            calledExpression: withIdentifier,
            leftParen: TokenSyntax.leftParenToken(),
            arguments: LabeledExprListSyntax([
                LabeledExprSyntax(
                    expression: ExprSyntax(
                        StringLiteralExprSyntax(
                            openingQuote: .stringQuoteToken(),
                            segments: StringLiteralSegmentListSyntax([
                                .stringSegment(StringSegmentSyntax(content: .stringSegment(typeHierarchyPrefix)))
                            ]),
                            closingQuote: .stringQuoteToken()
                        )
                    )
                )
            ]),
            rightParen: TokenSyntax.rightParenToken()
        )

        return ExprSyntax(withIdentifierCall)
    }

    // Helper method to wrap an expression in a Group
    private func wrapInGroup(_ expr: some ExprSyntaxProtocol) -> ExprSyntax {
        let groupExpr = DeclReferenceExprSyntax(
            baseName: TokenSyntax.identifier("Group")
        )

        // Create the function call for Group { expr } without parentheses
        let groupCall = FunctionCallExprSyntax(
            calledExpression: groupExpr,
            leftParen: nil,
            arguments: LabeledExprListSyntax([]),
            rightParen: nil,
            trailingClosure: ClosureExprSyntax(
                leftBrace: TokenSyntax.leftBraceToken(),
                statements: CodeBlockItemListSyntax([
                    CodeBlockItemSyntax(
                        item: .expr(ExprSyntax(expr))
                    )
                ]),
                rightBrace: TokenSyntax.rightBraceToken()
            )
        )

        return ExprSyntax(groupCall)
    }
}
