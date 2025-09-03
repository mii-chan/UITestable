import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

#if canImport(UITestableMacros)
import UITestableMacros

private let testMacros: [String: Macro.Type] = [
    "UITestable": UITestableMacro.self,
]
#endif

final class UITestableTests {
    @Test
    func testCombinedFunctionality() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                var body: some View {
                    _body()
                }

                @UITestable
                @ViewBuilder
                func _body() -> some View {
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
                    _body()
                }
                @ViewBuilder
                func _body() -> some View {
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
    func testCombined_withModifier() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                var body: some View {
                    _body()
                }

                @UITestable
                @ViewBuilder
                func _body() -> some View {
                    VStack {
                        Button("Button1") {
                            print("tapped Button1")
                        }
                        Text("title")
                    }
                    .padding(8)
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    _body()
                }
                @ViewBuilder
                func _body() -> some View {
                    VStack {
                                Button("Button1") {
                                    print("tapped Button1")
                                }
                                .accessibilityIdentifier("ContentView_Button1")
                                Text("title")
                            }
                            .padding(8)
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
    func testCombined_controlFlow() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                let flag: Bool = false

                var body: some View {
                    _body()
                }

                @UITestable
                @ViewBuilder
                func _body() -> some View {
                    if flag {
                        VStack {
                            Button("Button1") {
                                print("tapped Button1")
                            }
                        }
                    } else {
                        HStack {
                            Button("Button2") {
                                print("tapped Button2")
                            }
                        }
                    }
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                let flag: Bool = false

                var body: some View {
                    _body()
                }
                @ViewBuilder
                func _body() -> some View {
                    Group {
                            if flag {
                                VStack {
                                    Button("Button1") {
                                        print("tapped Button1")
                                    }
                                    .accessibilityIdentifier("ContentView_Button1")
                                }
                            } else {
                                HStack {
                                    Button("Button2") {
                                        print("tapped Button2")
                                    }
                                    .accessibilityIdentifier("ContentView_Button2")
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
    func testRespectExistingAccessibilityIdentifiers() throws {
        #if canImport(UITestableMacros)
        assertMacroExpansion(
            """
            struct ContentView: View {
                var body: some View {
                    _body()
                }

                @UITestable
                @ViewBuilder
                func _body() -> some View {
                    VStack {
                        Button("Button1") {
                            print("tapped Button1")
                        }
                        .accessibilityIdentifier("CustomButton1")
                    }
                    .accessibilityIdentifier("CustomView")
                }
            }
            """,
            expandedSource: """
            struct ContentView: View {
                var body: some View {
                    _body()
                }
                @ViewBuilder
                func _body() -> some View {
                    VStack {
                                Button("Button1") {
                                    print("tapped Button1")
                                }
                                .accessibilityIdentifier("CustomButton1")
                            }
                            .accessibilityIdentifier("CustomView")
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
