import SwiftUI
import GameController
import AppKit
import Combine

class GamepadMappingViewModel: ObservableObject {
    @Published var controllers: [GCController] = []
    @Published var selectedController: GCController?
    @Published var isSupported = true
    @Published var pressedButtons: [String: Bool] = [:]
    @Published var mappings: [MappingKey: InputMapping] = [:]
    @Published var leftStick = StickConfig()
    @Published var rightStick = StickConfig()
    @Published var swapFaceButtons: Bool = false
    @Published var isLeftStickMoving = false
    @Published var isRightStickMoving = false
    @Published var logText: String = ""
    @Published var profiles: [GamepadProfile] = []
    @Published var selectedProfileID: UUID = UUID()
    
    private var inputHandler: InputHandler?
    private let persistenceManager = PersistenceManager()
    private var cancellables = Set<AnyCancellable>()
    private let configChangeSubject = PassthroughSubject<Void, Never>()
    private var isLoadingProfile = false
    
    init() {
        setupObservers()
        loadConfig()
        
        // Watch for configuration selection changes
        $selectedProfileID
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] id in
                self?.loadProfile(id: id)
            }
            .store(in: &cancellables)
        
        let properties: [AnyPublisher<Void, Never>] = [
            $mappings.map { _ in () }.eraseToAnyPublisher(),
            $leftStick.map { _ in () }.eraseToAnyPublisher(),
            $rightStick.map { _ in () }.eraseToAnyPublisher(),
            $swapFaceButtons.map { _ in () }.eraseToAnyPublisher(),
            configChangeSubject.eraseToAnyPublisher()
        ]
        
        Publishers.MergeMany(properties)
            .sink { [weak self] _ in
                self?.updateInMemoryConfig()
            }
            .store(in: &cancellables)
            
        Publishers.MergeMany(properties)
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.onConfigChanged()
            }
            .store(in: &cancellables)
    }
    
    private func setupObservers() {
        GCController.shouldMonitorBackgroundEvents = true
        refreshControllers()
        
        NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { [weak self] _ in
            self?.refreshControllers()
        }
        NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
            self?.refreshControllers()
        }
    }
    
    private func refreshControllers() {
        controllers = GCController.controllers()
        if selectedController == nil || !controllers.contains(selectedController!) {
            selectedController = controllers.first
        }
        setupInputMonitoring()
    }
    
    func saveConfig(to url: URL? = nil) {
        let appConfig = AppConfig(selectedProfileID: selectedProfileID, profiles: profiles)
        persistenceManager.save(appConfig, to: url)
    }
    
    func loadConfig(from url: URL? = nil) {
        let appConfig = persistenceManager.loadAppConfig(from: url)
        self.profiles = appConfig.profiles
        self.selectedProfileID = appConfig.selectedProfileID
        loadProfile(id: self.selectedProfileID)
    }
    
    func createNewProfile() {
        let newConf = GamepadProfile(
            name: "Profile \(profiles.count + 1)"
        )
        profiles.append(newConf)
        selectedProfileID = newConf.id
    }
    
    func updateProfileName(_ name: String) {
        if let index = profiles.firstIndex(where: { $0.id == selectedProfileID }) {
            profiles[index].name = name
            configChangeSubject.send()
        }
    }
    
    func deleteProfile() {
        guard let index = profiles.firstIndex(where: { $0.id == selectedProfileID }) else { return }
        
        profiles.remove(at: index)
        
        if profiles.isEmpty {
            let defaultConf = GamepadProfile.defaultProfile()
            profiles.append(defaultConf)
        }
        
        // Ensure a valid configuration is selected
        if !profiles.contains(where: { $0.id == selectedProfileID }) {
            selectedProfileID = profiles.first!.id
        }
    }
    
    func resetProfile() {
        mappings = [:]
        leftStick = StickConfig()
        rightStick = StickConfig()
        swapFaceButtons = false
    }
    
    private func loadProfile(id: UUID) {
        guard let config = profiles.first(where: { $0.id == id }) else { return }
        
        isLoadingProfile = true
        self.leftStick = config.leftStick
        self.rightStick = config.rightStick
        self.swapFaceButtons = config.swapFaceButtons
        self.mappings = config.mappingDictionary
        isLoadingProfile = false
    }
    
    func onConfigChanged() {
        saveConfig()
        setupInputMonitoring()
    }
    
    private func updateInMemoryConfig() {
        guard !isLoadingProfile else { return }
        if let index = profiles.firstIndex(where: { $0.id == selectedProfileID }) {
            var config = profiles[index]
            config.leftStick = leftStick
            config.rightStick = rightStick
            config.swapFaceButtons = swapFaceButtons
            config.mappingDictionary = mappings
            profiles[index] = config
        }
    }
    
    func setupInputMonitoring() {
        inputHandler = nil
        
        guard let controller = selectedController else { return }
        
        guard let extendedGamepad = controller.extendedGamepad else {
            isSupported = false
            return
        }
        isSupported = true
        
        let config = InputHandler.HandlerConfig(
            mappings: mappings,
            leftStick: leftStick,
            rightStick: rightStick,
            swapFaceButtons: swapFaceButtons
        )
        
        inputHandler = InputHandler(
            gamepad: GCGamepadAdapter(gamepad: extendedGamepad),
            config: config,
            logAction: { [weak self] message in
                guard let self = self, NSApplication.shared.isActive else { return }
                DispatchQueue.main.async {
                    self.logText.append("\(message)\n")
                    if self.logText.count > 10000 { self.logText = String(self.logText.suffix(8000)) }
                }
            },
            updatePressedButton: { [weak self] key, pressed in
                self?.pressedButtons[key] = pressed
            },
            updateStickMoving: { [weak self] isLeft, isMoving in
                if isLeft {
                    self?.isLeftStickMoving = isMoving
                } else {
                    self?.isRightStickMoving = isMoving
                }
            }
        )
    }
    
    func mappingText(for key: MappingKey) -> String {
        return mappings[key]?.name ?? ""
    }
}
