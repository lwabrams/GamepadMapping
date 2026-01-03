//
//  PersistenceManagerTests.swift
//  GamepadMappingTests
//
//  Created by Loren Abrams on 1/3/26.
//

import Testing
import Foundation
@testable import GamepadMapping

@MainActor
struct PersistenceManagerTests {

    // Helper to generate a unique temporary URL for each test
    private func makeTempURL() -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
    }
    
    @Test func testSaveAndLoadGeneric() async throws {
        let manager = PersistenceManager()
        let url = makeTempURL()
        let original = StickConfig(mode: .mouse, speed: 20.0, movePointer: false)
        
        // Test Save
        manager.save(original, to: url)
        
        // Verify file exists
        #expect(FileManager.default.fileExists(atPath: url.path))
        
        // Test Load
        let loaded: StickConfig? = manager.load(from: url)
        #expect(loaded != nil)
        #expect(loaded == original)
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    @Test func testLoadReturnsNilIfFileDoesNotExist() async throws {
        let manager = PersistenceManager()
        let url = makeTempURL() // Random new URL
        
        let loaded: StickConfig? = manager.load(from: url)
        #expect(loaded == nil)
    }
    
    @Test func testLoadReturnsNilForCorruptedData() async throws {
        let manager = PersistenceManager()
        let url = makeTempURL()
        
        // Write invalid JSON
        try "Not JSON".write(to: url, atomically: true, encoding: .utf8)
        
        let loaded: StickConfig? = manager.load(from: url)
        #expect(loaded == nil)
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    @Test func testLoadAppConfig_ReturnsDefaultWhenNoFile() async throws {
        let manager = PersistenceManager()
        let url = makeTempURL()
        
        let config = manager.loadAppConfig(from: url)
        
        // Should return a default configuration with one profile
        #expect(config.profiles.count == 1)
        #expect(config.profiles.first?.name == "Default configuration profile")
        
        // Default profile should handle left/right stick defaults
        #expect(config.profiles.first?.leftStick.mode == StickMode.none)
    }

    @Test func testLoadAppConfig_LoadsNewFormat() async throws {
        let manager = PersistenceManager()
        let url = makeTempURL()
        
        let profile = GamepadProfile(id: UUID(), name: "Custom Profile")
        let appConfig = AppConfig(selectedProfileID: profile.id, profiles: [profile])
        
        manager.save(appConfig, to: url)
        
        let loadedConfig = manager.loadAppConfig(from: url)
        
        #expect(loadedConfig.profiles.count == 1)
        #expect(loadedConfig.profiles.first?.name == "Custom Profile")
        #expect(loadedConfig.selectedProfileID == profile.id)
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
    
    @Test func testLoadAppConfig_MigratesLegacyFormat() async throws {
        let manager = PersistenceManager()
        let url = makeTempURL()
        
        // Create legacy config
        let legacyConfig = SavedConfig(
            leftStick: StickConfig(mode: .dpad, speed: 10),
            rightStick: StickConfig(mode: .mouse, speed: 5),
            swapFaceButtons: true,
            mappings: ["Buttons|A": InputMapping(type: .key, code: 4, value: 1, name: "A")]
        )
        
        // Save as SavedConfig (simulating old file)
        manager.save(legacyConfig, to: url)
        
        // Load via loadAppConfig (should trigger migration)
        let loadedConfig = manager.loadAppConfig(from: url)
        
        #expect(loadedConfig.profiles.count == 1)
        let profile = loadedConfig.profiles.first!
        
        // Check migrated values
        #expect(profile.leftStick.mode == .dpad)
        #expect(profile.rightStick.mode == .mouse)
        #expect(profile.swapFaceButtons == true)
        
        // Check mapping migration
        // Note: MappingKey.storageKey for "Buttons|A" is "Buttons|A"
        #expect(profile.mappings["Buttons|A"]?.name == "A")
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
}
