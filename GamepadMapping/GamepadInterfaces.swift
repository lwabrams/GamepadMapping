import Foundation
import GameController

// MARK: - Input Simulator Protocol

protocol InputSimulatorProtocol {
    func simulate(mapping: InputMapping, pressed: Bool)
    func simulateMouseMovement(dx: CGFloat, dy: CGFloat, movePointer: Bool)
}

// MARK: - Gamepad Interface Protocols

protocol ButtonInterface: AnyObject {
    func setHandler(_ handler: @escaping (_ pressed: Bool) -> Void)
}

protocol AxisInterface: AnyObject {
    var value: Float { get }
}

protocol DirectionPadInterface: AnyObject {
    var xAxisValue: Float { get }
    var yAxisValue: Float { get }
    
    var up: ButtonInterface? { get }
    var down: ButtonInterface? { get }
    var left: ButtonInterface? { get }
    var right: ButtonInterface? { get }
}

protocol GamepadInterface: AnyObject {
    // Face Buttons
    var buttonA: ButtonInterface? { get }
    var buttonB: ButtonInterface? { get }
    var buttonX: ButtonInterface? { get }
    var buttonY: ButtonInterface? { get }
    
    // Shoulders/Triggers
    var leftShoulder: ButtonInterface? { get }
    var leftTrigger: ButtonInterface? { get }
    var rightShoulder: ButtonInterface? { get }
    var rightTrigger: ButtonInterface? { get }
    
    // Stick Buttons
    var leftThumbstickButton: ButtonInterface? { get }
    var rightThumbstickButton: ButtonInterface? { get }
    
    // Menu/Options
    var buttonOptions: ButtonInterface? { get }
    var buttonMenu: ButtonInterface? { get }
    
    // Directional
    var dpad: DirectionPadInterface? { get }
    var leftThumbstick: DirectionPadInterface? { get }
    var rightThumbstick: DirectionPadInterface? { get }
}
