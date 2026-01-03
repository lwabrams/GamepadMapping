import SwiftUI

struct StickConfigurationView: View {
    let title: String
    @Binding var config: StickConfig
    let isMoving: Bool
    let section: MappingSection
    @ObservedObject var viewModel: GamepadMappingViewModel
    @Binding var activeMappingTarget: MappingTarget?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .frame(width: 75, alignment: .trailing)
                    .fontWeight(isMoving ? .bold : .regular)
                Picker("", selection: $config.mode) {
                    Text("Select a mapping")
                        .font(.body.italic())
                        .foregroundColor(Color(white: 0.4))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .allowsHitTesting(false)
                        .tag(StickMode.none)
                    Text("Map to mouse").tag(StickMode.mouse)
                    Text("Simulate a direction pad").tag(StickMode.dpad)
                }
                .labelsHidden()
            }
            
            if config.mode == .mouse {
                HStack {
                    Text("Speed")
                        .frame(width: 75, alignment: .trailing)
                    Slider(value: $config.speed, in: 0...30)
                }
                .padding(.leading, 10)
                
                HStack {
                    Text("Delta only")
                        .frame(width: 170, alignment: .trailing)
                    Toggle("", isOn: Binding(get: { !config.movePointer }, set: { config.movePointer = !$0 }))
                        .labelsHidden()
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.secondary)
                        .help("When enabled, the mouse cursor remains stationary while sending movement deltas. Recommended for first-person games.")
                }
                .padding(.leading, 10)
            }
            
            if config.mode == .dpad {
                DirectionalMappingListView(
                    section: section,
                    viewModel: viewModel,
                    activeMappingTarget: $activeMappingTarget,
                    isPressedPredicate: { _ in false }
                )
                .padding(.leading, 10)
            }
        }
    }
}
