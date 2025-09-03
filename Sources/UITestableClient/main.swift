import SwiftUI
#if DEBUG
import UITestable
#endif

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
            Button("Button1") {
                print("tapped Button1")
            }
        }
    }
}
