//
//  WorkflowTests.swift
//  GamepadMappingTests
//
//  Created by Loren Abrams on 1/3/26.
//

import Testing
import Foundation
import CoreGraphics
@testable import GamepadMapping

// MARK: - Mocks

class MockInputSimulator: InputSimulatorProtocol {
    var lastSimulatedMapping: InputMapping?
    var lastSimulatedPressed: Bool?
    var simulatedMouseMoves: [(dx: CGFloat, dy: CGFloat, movePointer: Bool)] = []
    
    func simulate(mapping: InputMapping, pressed: Bool) {
        lastSimulatedMapping = mapping
        lastSimulatedPressed = pressed
    }
    
    func simulateMouseMovement(dx: CGFloat, dy: CGFloat, movePointer: Bool) {
        simulatedMouseMoves.append((dx: dx, dy: dy, movePointer: movePointer))
    }
}

class MockButton: ButtonInterface {
    var handler: ((Bool) -> Void)?
    
    func setHandler(_ handler: @escaping (Bool) -> Void) {
        self.handler = handler
    }
    
    func press() {
        handler?(true)
    }
    
    func release() {
        handler?(false)
    }
}

class MockDirectionPad: DirectionPadInterface {
    var xAxisValue: Float = 0
    var yAxisValue: Float = 0
    
    // We only need basic buttons for the interface compliance, or real mocks if we test dpad-buttons
    var up: ButtonInterface? = MockButton()
    var down: ButtonInterface? = MockButton()
    var left: ButtonInterface? = MockButton()
    var right: ButtonInterface? = MockButton()
}

class MockGamepad: GamepadInterface {
    var buttonA: ButtonInterface? = MockButton()
    var buttonB: ButtonInterface? = MockButton()
    var buttonX: ButtonInterface? = MockButton()
    var buttonY: ButtonInterface? = MockButton()
    
    var leftShoulder: ButtonInterface? = MockButton()
    var leftTrigger: ButtonInterface? = MockButton()
    var rightShoulder: ButtonInterface? = MockButton()
    var rightTrigger: ButtonInterface? = MockButton()
    
    var leftThumbstickButton: ButtonInterface? = MockButton()
    var rightThumbstickButton: ButtonInterface? = MockButton()
    
    var buttonOptions: ButtonInterface? = MockButton()
    var buttonMenu: ButtonInterface? = MockButton()
    
    var dpad: DirectionPadInterface? = MockDirectionPad()
    var leftThumbstick: DirectionPadInterface? = MockDirectionPad()
    var rightThumbstick: DirectionPadInterface? = MockDirectionPad()
}

@MainActor
struct WorkflowTests {

    @Test func testButtonMappingTriggersSimulator() async throws {
        // Setup
        let gamepad = MockGamepad()
        let simulator = MockInputSimulator()
        
        let mappingA = InputMapping(type: .key, code: 49, value: 0, name: "Space") // 49 is Space
        let mappings: [MappingKey: InputMapping] = [
            MappingKey(section: .buttons, label: "A"): mappingA
        ]
        
        let config = InputHandler.HandlerConfig(
            mappings: mappings,
            leftStick: StickConfig(),
            rightStick: StickConfig(),
            swapFaceButtons: false
        )
        
        // Hold reference to handler so it doesn't deinit
        let handler = InputHandler(
            gamepad: gamepad,
            config: config,
            simulator: simulator,
            logAction: { _ in },
            updatePressedButton: { _, _ in },
            updateStickMoving: { _, _ in }
        )
        
        // Act: Press A
        (gamepad.buttonA as? MockButton)?.press()
        
        // Assert
        #expect(simulator.lastSimulatedMapping == mappingA)
        #expect(simulator.lastSimulatedPressed == true)
        
        // Act: Release A
        (gamepad.buttonA as? MockButton)?.release()
        
        // Assert
        #expect(simulator.lastSimulatedPressed == false)
        
        // Keep handler alive until here
        _ = handler
    }

    @Test func testSwapFaceButtons() async throws {
        // Setup
        let gamepad = MockGamepad()
        let simulator = MockInputSimulator()
        
        let mappingB = InputMapping(type: .key, code: 50, value: 0, name: "BKey")
        // We map B to BKey.
        // But we swap face buttons. So Physical A -> Logical B -> Should trigger B mapping.
        
        let mappings: [MappingKey: InputMapping] = [
            MappingKey(section: .buttons, label: "B"): mappingB
        ]
        
        let config = InputHandler.HandlerConfig(
            mappings: mappings,
            leftStick: StickConfig(),
            rightStick: StickConfig(),
            swapFaceButtons: true // Enabled
        )
        
        let handler = InputHandler(
            gamepad: gamepad,
            config: config,
            simulator: simulator,
            logAction: { _ in },
            updatePressedButton: { _, _ in },
            updateStickMoving: { _, _ in }
        )
        
        // Act: Press Physical A
        (gamepad.buttonA as? MockButton)?.press()
        
        // Assert: Expect Logical B mapping (which is present)
        #expect(simulator.lastSimulatedMapping == mappingB)
        
        _ = handler
    }

    @Test func testStickAsMouse() async throws {
        // Setup
        let gamepad = MockGamepad()
        let simulator = MockInputSimulator()
        
        var stickConfig = StickConfig()
        stickConfig.mode = .mouse
        stickConfig.speed = 10.0
        stickConfig.movePointer = true
        
        let config = InputHandler.HandlerConfig(
            mappings: [:],
            leftStick: stickConfig,
            rightStick: StickConfig(),
            swapFaceButtons: false
        )
        
        let handler = InputHandler(
            gamepad: gamepad,
            config: config,
            simulator: simulator,
            logAction: { _ in },
            updatePressedButton: { _, _ in },
            updateStickMoving: { _, _ in }
        )
        
        // Act: Move Left Stick
        // InputHandler polls on a timer. We need to wait for the timer to fire.
        // We can simulate the stick value change.
        (gamepad.leftThumbstick as? MockDirectionPad)?.xAxisValue = 1.0 // Full Right
        (gamepad.leftThumbstick as? MockDirectionPad)?.yAxisValue = 0.5 // Half Up
        
        // Wait for polling (approx 0.016s)
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        
        // Assert
        #expect(!simulator.simulatedMouseMoves.isEmpty)
        if let move = simulator.simulatedMouseMoves.last {
            // x = 1.0 * 10.0 = 10.0
            // y = 0.5 * 10.0 = 5.0. BUT processStick inverts Y for mouse delta: dy = -y * speed = -5.0
            // Let's check logic:
            // InputHandler: let dy = CGFloat(-y * config.speed)
            // So expected dx=10, dy=-5
            
            #expect(abs(move.dx - 10.0) < 0.1)
            #expect(abs(move.dy - (-5.0)) < 0.1)
            #expect(move.movePointer == true)
        }
        
        _ = handler
    }

    @Test func testStickAsDPad() async throws {
        // Setup
        let gamepad = MockGamepad()
        let simulator = MockInputSimulator()
        
        var stickConfig = StickConfig()
        stickConfig.mode = .dpad
        
        let mappingUp = InputMapping(type: .key, code: 126, value: 0, name: "UpArrow")
        let mappings: [MappingKey: InputMapping] = [
            MappingKey(section: .leftStick, label: "Up"): mappingUp
        ]
        
        let config = InputHandler.HandlerConfig(
            mappings: mappings,
            leftStick: stickConfig,
            rightStick: StickConfig(),
            swapFaceButtons: false
        )
        
        let handler = InputHandler(
            gamepad: gamepad,
            config: config,
            simulator: simulator,
            logAction: { _ in },
            updatePressedButton: { _, _ in },
            updateStickMoving: { _, _ in }
        )
        
        // Act: Move Left Stick Up
        (gamepad.leftThumbstick as? MockDirectionPad)?.yAxisValue = 1.0
        
        // Wait for polling
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Assert
        #expect(simulator.lastSimulatedMapping == mappingUp)
        #expect(simulator.lastSimulatedPressed == true)
        
        // Act: Return to center
        (gamepad.leftThumbstick as? MockDirectionPad)?.yAxisValue = 0.0
        
        // Wait for polling
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Assert
        #expect(simulator.lastSimulatedPressed == false)
        
        _ = handler
    }
}
