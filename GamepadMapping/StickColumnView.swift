import SwiftUI

struct StickColumnView: View {
    @ObservedObject var viewModel: GamepadMappingViewModel
    @Binding var activeMappingTarget: MappingTarget?
    
    var body: some View {
        VStack {
            Text("Sticks")
                .font(.headline)
                .underline()
            ScrollView {
                VStack(alignment: .leading) {
                    StickConfigurationView(
                        title: "Left Stick",
                        config: $viewModel.leftStick,
                        isMoving: viewModel.isLeftStickMoving,
                        section: .leftStick,
                        viewModel: viewModel,
                        activeMappingTarget: $activeMappingTarget
                    )
                    
                    StickConfigurationView(
                        title: "Right Stick",
                        config: $viewModel.rightStick,
                        isMoving: viewModel.isRightStickMoving,
                        section: .rightStick,
                        viewModel: viewModel,
                        activeMappingTarget: $activeMappingTarget
                    )
                }
                .padding()
            }
        }
    }
}
