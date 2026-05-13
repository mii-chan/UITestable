import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

#if canImport(UITestableMacros)
import UITestableMacros

private let testMacros: [String: Macro.Type] = [
    "UITestableView": UITestableViewMacro.self,
]
#endif

final class UITestableViewMacroTests {
    @Test
    func testViewOnly() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                @UITestableView
                var body: some View {
                    VStack {
                        Text("title")
                    }
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    VStack {
                                Text("title")
                            }
                            .background(
                                Color.clear
                                    .accessibilityIdentifier("ContentView")
                            )
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
    func testReturn() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                @UITestableView
                var body: some View {
                    return VStack {
                        Text("title")
                    }
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    return VStack {
                                Text("title")
                            }
                    .background(
                        Color.clear
                            .accessibilityIdentifier("ContentView")
                    )
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
    func testIf() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                let flag: Bool = false

                @UITestableView
                var body: some View {
                    if flag {
                        VStack {
                            Text("title")
                        }
                    } else {
                        HStack {
                            Text("another title")
                        }
                    }
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                let flag: Bool = false
                var body: some View {
                    Group {
                            if flag {
                                VStack {
                                    Text("title")
                                }
                            } else {
                                HStack {
                                    Text("another title")
                                }
                            }
                    }
                    .background(
                        Color.clear
                            .accessibilityIdentifier("ContentView")
                    )
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
    func testNoButtonModifiersApplied() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                @UITestableView
                var body: some View {
                    VStack {
                        Button("Button1") {
                            print("tapped Button1")
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
                            }
                            .background(
                                Color.clear
                                    .accessibilityIdentifier("ContentView")
                            )
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
                @UITestableView
                var body: some View {
                    VStack {
                        Text("title")
                    }
                    .accessibilityIdentifier("ContentView")
                    .padding(8)
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    VStack {
                                Text("title")
                            }
                            .accessibilityIdentifier("ContentView")
                            .padding(8)
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
