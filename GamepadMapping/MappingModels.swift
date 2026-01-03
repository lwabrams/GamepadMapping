import Foundation

enum MappingSection: String, Codable {
    case buttons = "Buttons"
    case dpad = "DPad"
    case leftStick = "LeftStick"
    case rightStick = "RightStick"
}

struct MappingKey: Hashable, Codable {
    let section: MappingSection
    let label: String
    
    var storageKey: String {
        return "\(section.rawValue)|\(label)"
    }
    
    init(section: MappingSection, label: String) {
        self.section = section
        self.label = label
    }
    
    init?(storageKey: String) {
        let parts = storageKey.split(separator: "|")
        guard parts.count == 2, let section = MappingSection(rawValue: String(parts[0])) else { return nil }
        self.section = section
        self.label = String(parts[1])
    }
}

struct MappingTarget: Identifiable {
    let id = UUID()
    let key: MappingKey
    let label: String
}

enum StickMode: String, CaseIterable, Codable {
    case none = ""
    case mouse = "Map to mouse axes"
    case dpad = "Simulate a direction pad"
}

struct InputMapping: Codable, Equatable {
    enum InputType: String, Codable {
        case key
        case mouseButton
        case scroll
    }
    let type: InputType
    let code: Int
    let value: Int
    let name: String
}

struct StickConfig: Codable, Equatable {
    var mode: StickMode = .none
    var speed: Double = 15.0
    var movePointer: Bool = true
}

struct SavedConfig: Codable {
    var leftStick: StickConfig
    var rightStick: StickConfig
    var swapFaceButtons: Bool?
    var mappings: [String: InputMapping]
}

struct GamepadProfile: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String = "Default configuration profile"
    var leftStick: StickConfig = StickConfig()
    var rightStick: StickConfig = StickConfig()
    var swapFaceButtons: Bool = false
    var mappings: [String: InputMapping] = [:]
    
    static func defaultProfile() -> GamepadProfile {
        return GamepadProfile()
    }
    
    var mappingDictionary: [MappingKey: InputMapping] {
        get {
            mappings.reduce(into: [:]) { dict, pair in
                if let key = MappingKey(storageKey: pair.key) {
                    dict[key] = pair.value
                }
            }
        }
        set {
            mappings = newValue.reduce(into: [:]) { dict, pair in
                dict[pair.key.storageKey] = pair.value
            }
        }
    }
}

struct AppConfig: Codable {
    var selectedProfileID: UUID
    var profiles: [GamepadProfile]
}