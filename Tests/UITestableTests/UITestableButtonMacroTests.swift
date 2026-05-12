import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

#if canImport(UITestableMacros)
import UITestableMacros

private let testMacros: [String: Macro.Type] = [
    "UITestableButton": UITestableButtonMacro.self,
]
#endif

final class UITestableButtonMacroTests {
    @Test
    func testButtonOnly() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                @UITestableButton
                var body: some View {
                    Button("Button1") {
                        print("tapped Button1")
                    }
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    Button("Button1") {
                                print("tapped Button1")
                            }
                            .accessibilityIdentifier("ContentView_Button1")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    @Test
    func testMultipleButtons() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                @UITestableButton
                var body: some View {
                    VStack {
                        Button("Button1") {
                            print("tapped Button1")
                        }

                        Button("Button2") {
                            print("tapped Button2")
                        }
                    }
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    VStack {
                                Button("Button1") {
                                    print("tapped Button1")
                                }
                                .accessibilityIdentifier("ContentView_Button1")

                                Button("Button2") {
                                    print("tapped Button2")
                                }
                                .accessibilityIdentifier("ContentView_Button2")
                            }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    @Test
    func testRespectExistingAccessibilityIdentifiers() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                @UITestableButton
                var body: some View {
                    VStack {
                        Button("Button1") {
                            print("tapped Button1")
                        }
                        .accessibilityIdentifier("Button1_identifier")
                    }
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    VStack {
                                Button("Button1") {
                                    print("tapped Button1")
                                }
                                .accessibilityIdentifier("Button1_identifier")
                            }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    @Test
    func testNoRootViewIdentifierApplied() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                @UITestableButton
                var body: some View {
                    VStack {
                        Text("Hello")
                    }
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    VStack {
                                Text("Hello")
                            }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
