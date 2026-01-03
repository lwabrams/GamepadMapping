import Foundation
import GameController
import AppKit

class InputHandler {
    struct HandlerConfig {
        var mappings: [MappingKey: InputMapping]
        var leftStick: StickConfig
        var rightStick: StickConfig
        var swapFaceButtons: Bool
    }

    private let gamepad: GamepadInterface
    private let config: HandlerConfig
    private let logAction: (String) -> Void
    private let updatePressedButton: (String, Bool) -> Void
    private let updateStickMoving: (Bool, Bool) -> Void
    
    private let simulator: InputSimulatorProtocol
    private var timer: Timer?
    
    // State for stick-as-dpad to prevent event spamming
    private var leftStickState: [String: Bool] = [:]
    private var rightStickState: [String: Bool] = [:]

    init(gamepad: GamepadInterface,
         config: HandlerConfig,
         simulator: InputSimulatorProtocol = InputSimulator(),
         logAction: @escaping (String) -> Void,
         updatePressedButton: @escaping (String, Bool) -> Void,
         updateStickMoving: @escaping (Bool, Bool) -> Void) {
        self.gamepad = gamepad
        self.config = config
        self.simulator = simulator
        self.logAction = logAction
        self.updatePressedButton = updatePressedButton
        self.updateStickMoving = updateStickMoving
        
        setupHandlers()
        startStickPolling()
    }
    
    deinit {
        timer?.invalidate()
    }

    private func setupHandlers() {
        // Face Buttons
        bind(button: gamepad.buttonA, name: "A")
        bind(button: gamepad.buttonB, name: "B")
        bind(button: gamepad.buttonX, name: "X")
        bind(button: gamepad.buttonY, name: "Y")
        
        // Shoulders/Triggers
        bind(button: gamepad.leftShoulder, name: "Left 1")
        bind(button: gamepad.leftTrigger, name: "Left 2")
        bind(button: gamepad.rightShoulder, name: "Right 1")
        bind(button: gamepad.rightTrigger, name: "Right 2")
        
        // Stick Buttons
        bind(button: gamepad.leftThumbstickButton, name: "Left Stick")
        bind(button: gamepad.rightThumbstickButton, name: "Right Stick")
        
        // Menu/Options
        bind(button: gamepad.buttonOptions, name: "Select")
        bind(button: gamepad.buttonMenu, name: "Start")
        
        // D-Pad
        if let dpad = gamepad.dpad {
            bind(button: dpad.up, name: "Up", section: .dpad)
            bind(button: dpad.down, name: "Down", section: .dpad)
            bind(button: dpad.left, name: "Left", section: .dpad)
            bind(button: dpad.right, name: "Right", section: .dpad)
        }
    }
    
    private func bind(button: ButtonInterface?, name: String, section: MappingSection = .buttons) {
        guard let button = button else { return }
        
        let uiKey: String
        if section == .dpad {
            uiKey = name
        } else {
            uiKey = Constants.controllerButtonNameToId[name] ?? name
        }

        button.setHandler { [weak self] pressed in
            guard let self = self else { return }
            
            self.updatePressedButton(uiKey, pressed)
            
            let effectiveName = self.effectiveButtonName(for: name, section: section)
            
            let mappingKey = MappingKey(section: section, label: effectiveName)
            if let mapping = self.config.mappings[mappingKey] {
                self.simulator.simulate(mapping: mapping, pressed: pressed)
                if pressed {
                    self.logAction("\(effectiveName) \(pressed ? "pressed" : "released") -> \(mapping.name)")
                }
            }
        }
    }
    
    private func effectiveButtonName(for name: String, section: MappingSection) -> String {
        if section == .buttons && config.swapFaceButtons {
            switch name {
            case "A": return "B"
            case "B": return "A"
            case "X": return "Y"
            case "Y": return "X"
            default: return name
            }
        }
        return name
    }
    
    private func startStickPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.pollSticks()
        }
    }
    
    private func pollSticks() {
        if let left = gamepad.leftThumbstick {
            processStick(left, config: config.leftStick, section: .leftStick, state: &leftStickState)
        }
        if let right = gamepad.rightThumbstick {
            processStick(right, config: config.rightStick, section: .rightStick, state: &rightStickState)
        }
    }
    
    private func processStick(_ stick: DirectionPadInterface, config: StickConfig, section: MappingSection, state: inout [String: Bool]) {
        let x = Double(stick.xAxisValue)
        let y = Double(stick.yAxisValue)
        let isMoving = x * x + y * y > 0.1
        
        updateStickMoving(section == .leftStick, isMoving)
        
        if config.mode == .mouse && isMoving {
            let dx = CGFloat(x * config.speed)
            let dy = CGFloat(-y * config.speed)
            if config.movePointer {
                let current = CGEvent(source: nil)?.location ?? .zero
                let targetLoc = CGPoint(x: current.x + dx, y: current.y + dy)
                logAction(String(format: "%@ -> Mouse Move Delta (%.1f, %.1f) Loc (%.0f, %.0f)", section.rawValue, dx, dy, targetLoc.x, targetLoc.y))
            } else {
                logAction(String(format: "%@ -> Mouse Move Delta (%.1f, %.1f)", section.rawValue, dx, dy))
            }
            simulator.simulateMouseMovement(dx: dx, dy: dy, movePointer: config.movePointer)
        } else if config.mode == .dpad {
            let threshold: Float = 0.5
            let directions: [(String, Bool)] = [
                ("Up", stick.yAxisValue > threshold),
                ("Down", stick.yAxisValue < -threshold),
                ("Left", stick.xAxisValue < -threshold),
                ("Right", stick.xAxisValue > threshold)
            ]
            
            for (label, active) in directions {
                let wasActive = state[label] ?? false
                if active != wasActive {
                    state[label] = active
                    let mappingKey = MappingKey(section: section, label: label)
                    if let mapping = self.config.mappings[mappingKey] {
                        simulator.simulate(mapping: mapping, pressed: active)
                        if active {
                            logAction("\(section.rawValue) \(label) -> \(mapping.name)")
                        }
                    }
                }
            }
        }
    }
}
