import SwiftUI

struct MappingModalView: View {
    let target: MappingTarget
    @Binding var activeMappingTarget: MappingTarget?
    @Binding var mappings: [MappingKey: InputMapping]
    @State private var eventMonitor: Any?

    var body: some View {
        VStack(spacing: 20) {
            Text("Press a button on your keyboard or mouse to map the \(target.label) button")
                .multilineTextAlignment(.center)
            Button("Cancel") {
                activeMappingTarget = nil
            }
        }
        .padding()
        .frame(width: CGFloat(Constants.windowWidth-200), height: 150)
        .onAppear {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel]) { event in
                if event.type == .keyDown {
                    let name = keyName(for: event)
                    mappings[target.key] = InputMapping(type: .key, code: Int(event.keyCode), value: 0, name: name)
                    activeMappingTarget = nil
                    return nil
                } else if event.type == .scrollWheel {
                    if event.deltaY != 0 {
                        let name = event.deltaY > 0 ? "Scroll up" : "Scroll down"
                        let val = event.deltaY > 0 ? 1 : -1
                        mappings[target.key] = InputMapping(type: .scroll, code: 0, value: val, name: name)
                        activeMappingTarget = nil
                        return nil
                    }
                    return event
                } else { // Is a mouse button event
                    let name = "Mouse \(event.buttonNumber == 0 ? "left" : event.buttonNumber == 1 ? "right" : "button \(event.buttonNumber)")"
                    mappings[target.key] = InputMapping(type: .mouseButton, code: event.buttonNumber, value: 0, name: name)
                    activeMappingTarget = nil
                    return event
                }
            }
        }
        .onDisappear {
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
            }
        }
    }
    
    private func keyName(for event: NSEvent) -> String {
        if let knownKey = Constants.KeyCodeToKeyName[event.keyCode] {
            return "\(knownKey) (\(event.keyCode))"
        } else if let chars = event.charactersIgnoringModifiers {
            return "\(chars) (\(event.keyCode))"
        }
        return "Key \(event.keyCode)"
    }
}