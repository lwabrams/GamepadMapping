import SwiftUI

struct DirectionPadColumnView: View {
    @ObservedObject var viewModel: GamepadMappingViewModel
    @Binding var activeMappingTarget: MappingTarget?
    
    var body: some View {
        VStack {
            Text("Direction Pad")
                .font(.headline)
                .underline()
            ScrollView {
                DirectionalMappingListView(
                    section: .dpad,
                    viewModel: viewModel,
                    activeMappingTarget: $activeMappingTarget,
                    isPressedPredicate: { label in viewModel.pressedButtons[label] ?? false }
                )
            }
        }
    }
}
