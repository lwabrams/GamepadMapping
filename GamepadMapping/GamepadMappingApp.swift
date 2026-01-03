import SwiftUI

@main
struct GamepadMappingApp: App {
    var body: some Scene {
        WindowGroup("Gamepad to Keyboard/Mouse Mapping") {
            GamepadMappingView()
                .frame(width: CGFloat(Constants.windowWidth), height: CGFloat(Constants.windowHeight))
        }
    }
}
