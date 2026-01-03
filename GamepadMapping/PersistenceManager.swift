import Foundation

class PersistenceManager {
    private let defaultConfigURL: URL?

    init(filename: String = "config.json") {
        self.defaultConfigURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
    }

    func save<T: Encodable>(_ config: T, to url: URL? = nil) {
        guard let targetURL = url ?? defaultConfigURL else { return }
        if let data = try? JSONEncoder().encode(config) {
            try? data.write(to: targetURL)
        }
    }

    func load<T: Decodable>(from url: URL? = nil) -> T? {
        guard let targetURL = url ?? defaultConfigURL,
              let data = try? Data(contentsOf: targetURL) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func loadAppConfig(from url: URL? = nil) -> AppConfig {
        // Try loading new AppConfig format
        if let appConfig: AppConfig = load(from: url) {
            return appConfig
        }
        
        // Fallback: Try loading legacy SavedConfig and migrate
        if let legacyConfig: SavedConfig = load(from: url) {
            let defaultProfile = GamepadProfile(
                leftStick: legacyConfig.leftStick,
                rightStick: legacyConfig.rightStick,
                swapFaceButtons: legacyConfig.swapFaceButtons ?? false,
                mappings: legacyConfig.mappings
            )
            return AppConfig(selectedProfileID: defaultProfile.id, profiles: [defaultProfile])
        }
        
        // No config found, create default
        let defaultProfile = GamepadProfile.defaultProfile()
        return AppConfig(selectedProfileID: defaultProfile.id, profiles: [defaultProfile])
    }
}