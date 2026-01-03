import SwiftUI

struct ButtonsColumnView: View {
    @ObservedObject var viewModel: GamepadMappingViewModel
    @Binding var activeMappingTarget: MappingTarget?
    
    var body: some View {
        VStack {
            Text("Buttons")
                .font(.headline)
                .underline()
            
            HStack {
                Text("Swap A/B & X/Y")
                    .frame(width: 135, alignment: .trailing)
                Toggle("", isOn: $viewModel.swapFaceButtons)
                    .labelsHidden()
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.secondary)
                    .help("Swaps the A/B and X/Y button mappings. Necessary for some controllers.")
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .center)
            
            ScrollView {
                ForEach(Constants.controllerButtonNameAndId, id: \.0) { (name, symbol) in
                    let swappedSymbol = viewModel.swapFaceButtons ? Constants.controllerButtonNameToId[
                        Constants.controllerButtonIdToNameAfterSelectiveSwaps[symbol]!]! : symbol
                    let key = MappingKey(section: .buttons, label: name)
                    MappingRowView(label: name,
                               mappedText: viewModel.mappingText(for: key),
                               isPressed: viewModel.pressedButtons[swappedSymbol] ?? false,
                               action: { activeMappingTarget = MappingTarget(key: key, label: name) },
                               clearAction: { viewModel.mappings[key] = nil })
                }
            }
        }
    }
}
