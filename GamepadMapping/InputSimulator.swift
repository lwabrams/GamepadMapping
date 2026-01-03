import Foundation
import AppKit

/// A stateless service for creating and posting low-level `CGEvent`s.
class InputSimulator: InputSimulatorProtocol {
    func simulate(mapping: InputMapping, pressed: Bool) {
        guard !NSApplication.shared.isActive else { return }
        let source = CGEventSource(stateID: .hidSystemState)

        switch mapping.type {
        case .key:
            let keyEvent = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(mapping.code), keyDown: pressed)
            keyEvent?.post(tap: .cghidEventTap)
        case .mouseButton:
            let mouseLoc = CGEvent(source: nil)?.location ?? .zero
            var mouseType: CGEventType = .null
            var mouseButton: CGMouseButton = .left

            switch mapping.code {
            case 0: mouseType = pressed ? .leftMouseDown : .leftMouseUp; mouseButton = .left
            case 1: mouseType = pressed ? .rightMouseDown : .rightMouseUp; mouseButton = .right
            default: mouseType = pressed ? .otherMouseDown : .otherMouseUp; mouseButton = .center
            }

            if let mouseEvent = CGEvent(mouseEventSource: source, mouseType: mouseType, mouseCursorPosition: mouseLoc, mouseButton: mouseButton) {
                mouseEvent.post(tap: .cghidEventTap)
            }
        case .scroll:
            if pressed {
                let dy = Int32(mapping.value)
                if let scroll = CGEvent(scrollWheelEvent2Source: source, units: .line, wheelCount: 2, wheel1: dy, wheel2: 0, wheel3: 0) {
                    scroll.post(tap: .cghidEventTap)
                }
            }
        }
    }

    func simulateMouseMovement(dx: CGFloat, dy: CGFloat, movePointer: Bool) {
        guard !NSApplication.shared.isActive else { return }
        
        let current = CGEvent(source: nil)?.location ?? .zero
        let targetLoc = movePointer ? CGPoint(x: current.x + dx, y: current.y + dy) : current

        if let mouseEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: targetLoc, mouseButton: .left) {
            mouseEvent.setIntegerValueField(.mouseEventDeltaX, value: Int64(dx))
            mouseEvent.setIntegerValueField(.mouseEventDeltaY, value: Int64(dy))
            mouseEvent.post(tap: .cghidEventTap)
        }
    }
}