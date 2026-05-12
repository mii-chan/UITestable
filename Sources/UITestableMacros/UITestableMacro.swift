import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol UITestableBaseMacro: BodyMacro {
    static var applyButtonModifier: Bool { get }
    static var applyRootViewIdentifier: Bool { get }
}

extension UITestableBaseMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let body = declaration.body else {
            return []
        }

        let typeHierarchyPrefix = makeTypeHierarchyPrefix(from: context)
        var statements = body.statements

        // Apply button modifier if needed
        if applyButtonModifier {
            let rewriter = ButtonModifierRewriter(typeHierarchyPrefix: typeHierarchyPrefix)
            statements = rewriter.visit(CodeBlockSyntax(statements: statements)).statements
        }

        // Apply root view identifier if needed
        if applyRootViewIdentifier {
            let applier = RootViewIdentifierApplier(typeHierarchyPrefix: typeHierarchyPrefix)
            statements = applier.apply(to: statements)
        }

        return Array(statements)
    }

    private static func makeTypeHierarchyPrefix(from context: some MacroExpansionContext) -> String {
        context.lexicalContext
            .compactMap { node in
                if let structDecl = node.as(StructDeclSyntax.self) {
                    return structDecl.name.text
                }
                return nil
            }
            .reversed()
            .joined(separator: "_")
    }
}

// UITestableMacro - Applies both functionalities
public struct UITestableMacro: UITestableBaseMacro {
    public static var applyButtonModifier: Bool { true }
    public static var applyRootViewIdentifier: Bool { true }
}

// UITestableButtonMacro - Only applies Button modifier functionality
public struct UITestableButtonMacro: UITestableBaseMacro {
    public static var applyButtonModifier: Bool { true }
    public static var applyRootViewIdentifier: Bool { false }
}

// UITestableViewMacro - Only applies Root View Identifier functionality
public struct UITestableViewMacro: UITestableBaseMacro {
    public static var applyButtonModifier: Bool { false }
    public static var applyRootViewIdentifier: Bool { true }
}

@main
struct UITestablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UITestableMacro.self,
        UITestableButtonMacro.self,
        UITestableViewMacro.self,
    ]
}


