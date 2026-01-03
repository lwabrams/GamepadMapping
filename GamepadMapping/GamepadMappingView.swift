import SwiftUI
import GameController

struct GamepadMappingView: View {
    @StateObject private var model = GamepadMappingViewModel()
    @State private var activeMappingTarget: MappingTarget?
    
    var body: some View {
        if model.controllers.isEmpty {
            Text("No controllers available. Please connect/pair a controller to continue.")
        } else if !model.isSupported {
            Text("Unsupported controller connected.")
        } else {
            VSplitView {
                VStack(spacing: 0) {
                    MappingProfileView(viewModel: model, activeMappingTarget: $activeMappingTarget)
                    ControllerMappingView(viewModel: model, activeMappingTarget: $activeMappingTarget)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                SimulationLogView(logText: model.logText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .sheet(item: $activeMappingTarget) { target in
                MappingModalView(target: target, activeMappingTarget: $activeMappingTarget, mappings: $model.mappings)
            }
        }
    }
}
