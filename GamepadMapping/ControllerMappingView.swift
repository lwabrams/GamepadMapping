import SwiftUI

struct ControllerMappingView: View {
    @ObservedObject var viewModel: GamepadMappingViewModel
    @Binding var activeMappingTarget: MappingTarget?
    
    var body: some View {
        GeometryReader { geometry in
            // Basic three column layout, with the sticks column afforded slightly more space
            HStack(spacing: 0) {
                StickColumnView(viewModel: viewModel, activeMappingTarget: $activeMappingTarget)
                    .frame(width: geometry.size.width * 0.4)
                DirectionPadColumnView(viewModel: viewModel, activeMappingTarget: $activeMappingTarget)
                    .frame(width: geometry.size.width * 0.3)
                ButtonsColumnView(viewModel: viewModel, activeMappingTarget: $activeMappingTarget)
                    .frame(width: geometry.size.width * 0.3)
            }
        }
    }
}
