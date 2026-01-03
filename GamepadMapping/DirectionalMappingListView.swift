import SwiftUI

struct DirectionalMappingListView: View {
    let section: MappingSection
    @ObservedObject var viewModel: GamepadMappingViewModel
    @Binding var activeMappingTarget: MappingTarget?
    let isPressedPredicate: (String) -> Bool
    
    var body: some View {
        ForEach(["Up", "Down", "Left", "Right"], id: \.self) { label in
            let key = MappingKey(section: section, label: label)
            
            MappingRowView(label: label,
                       mappedText: viewModel.mappingText(for: key),
                       isPressed: isPressedPredicate(label),
                       action: { activeMappingTarget = MappingTarget(key: key, label: label) },
                       clearAction: { viewModel.mappings[key] = nil })
        }
    }
}