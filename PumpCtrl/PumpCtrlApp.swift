import SwiftUI

@main
struct PumpCtrlApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: 400,
                    minHeight: 350,
                    maxHeight: 500
                )
        }
        .defaultSize(width: 600, height: 400)
        .windowResizability(.contentSize)
     }
}
