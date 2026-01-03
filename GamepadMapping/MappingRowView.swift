import SwiftUI

struct MappingRowView: View {
    let label: String
    var mappedText: String = ""
    var labelWidth: CGFloat = 75
    var isPressed: Bool = false
    var action: () -> Void = {}
    var clearAction: () -> Void = {}
    
    var body: some View {
        HStack {
            Text(label)
                .frame(width: labelWidth, alignment: .trailing)
                .fontWeight(isPressed ? .bold : .regular)
            
            Text(mappedText.isEmpty ? "Click to map" : mappedText)
                .font(mappedText.isEmpty ? .body.italic() : .body)
                .foregroundColor(mappedText.isEmpty ? Color(white: 0.4) : .primary)
                .frame(maxWidth: .infinity, alignment: mappedText.isEmpty ? .center : .leading)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture { action() }
            .overlay(alignment: .trailing) {
                if !mappedText.isEmpty {
                    Button(action: clearAction) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 5)
                }
            }
        }
    }
}