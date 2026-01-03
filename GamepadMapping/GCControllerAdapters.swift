import GameController

// MARK: - GCController Adapters

class GCButtonAdapter: ButtonInterface {
    private let button: GCControllerButtonInput
    
    init(button: GCControllerButtonInput) {
        self.button = button
    }
    
    func setHandler(_ handler: @escaping (Bool) -> Void) {
        button.valueChangedHandler = { _, _, pressed in
            handler(pressed)
        }
    }
}

class GCDirectionPadAdapter: DirectionPadInterface {
    private let pad: GCControllerDirectionPad
    
    init(pad: GCControllerDirectionPad) {
        self.pad = pad
    }
    
    var xAxisValue: Float { pad.xAxis.value }
    var yAxisValue: Float { pad.yAxis.value }
    
    var up: ButtonInterface? { GCButtonAdapter(button: pad.up) }
    var down: ButtonInterface? { GCButtonAdapter(button: pad.down) }
    var left: ButtonInterface? { GCButtonAdapter(button: pad.left) }
    var right: ButtonInterface? { GCButtonAdapter(button: pad.right) }
}

class GCGamepadAdapter: GamepadInterface {
    private let gamepad: GCExtendedGamepad
    
    init(gamepad: GCExtendedGamepad) {
        self.gamepad = gamepad
    }
    
    var buttonA: ButtonInterface? { GCButtonAdapter(button: gamepad.buttonA) }
    var buttonB: ButtonInterface? { GCButtonAdapter(button: gamepad.buttonB) }
    var buttonX: ButtonInterface? { GCButtonAdapter(button: gamepad.buttonX) }
    var buttonY: ButtonInterface? { GCButtonAdapter(button: gamepad.buttonY) }
    
    var leftShoulder: ButtonInterface? { GCButtonAdapter(button: gamepad.leftShoulder) }
    var leftTrigger: ButtonInterface? { GCButtonAdapter(button: gamepad.leftTrigger) }
    var rightShoulder: ButtonInterface? { GCButtonAdapter(button: gamepad.rightShoulder) }
    var rightTrigger: ButtonInterface? { GCButtonAdapter(button: gamepad.rightTrigger) }
    
    var leftThumbstickButton: ButtonInterface? { gamepad.leftThumbstickButton.map { GCButtonAdapter(button: $0) } }
    var rightThumbstickButton: ButtonInterface? { gamepad.rightThumbstickButton.map { GCButtonAdapter(button: $0) } }
    
    var buttonOptions: ButtonInterface? { gamepad.buttonOptions.map { GCButtonAdapter(button: $0) } }
    var buttonMenu: ButtonInterface? { GCButtonAdapter(button: gamepad.buttonMenu) }
    
    var dpad: DirectionPadInterface? { GCDirectionPadAdapter(pad: gamepad.dpad) }
    var leftThumbstick: DirectionPadInterface? { GCDirectionPadAdapter(pad: gamepad.leftThumbstick) }
    var rightThumbstick: DirectionPadInterface? { GCDirectionPadAdapter(pad: gamepad.rightThumbstick) }
}
