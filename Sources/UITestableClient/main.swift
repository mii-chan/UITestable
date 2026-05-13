import SwiftUI
#if DEBUG
import UITestable
#endif

struct ContentView: View {
    #if DEBUG
    @UITestable
    #endif
    var body: some View {
        VStack {
            Button("Button1") {
                print("tapped Button1")
            }
        }
    }
}
