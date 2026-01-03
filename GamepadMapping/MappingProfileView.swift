import SwiftUI
import AppKit

struct MappingProfileView: View {
    @ObservedObject var viewModel: GamepadMappingViewModel
    @Binding var activeMappingTarget: MappingTarget?

    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 0) {
                TextField("Name", text: Binding(
                    get: { viewModel.profiles.first(where: { $0.id == viewModel.selectedProfileID })?.name ?? "" },
                    set: { viewModel.updateProfileName($0) }
                ))
                .textFieldStyle(.plain)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                
                Divider()
                    .padding(.vertical, 4)
                
                Menu {
                    ForEach(viewModel.profiles) { config in
                        Button(action: {
                            viewModel.selectedProfileID = config.id
                        }) {
                            if config.id == viewModel.selectedProfileID {
                                Label(config.name, systemImage: "checkmark")
                            } else {
                                Text(config.name)
                            }
                        }
                    }
                    Divider()
                    Button("Create New...") {
                        viewModel.createNewProfile()
                    }
                    Button("Delete Profile") {
                        viewModel.deleteProfile()
                    }
                } label: {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 16)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .frame(width: 24)
            }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
            )
            .frame(width: 250, height: 28)
            Spacer()
        }
        .padding()   
    }
}