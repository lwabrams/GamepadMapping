import SwiftUI

struct SimulationLogView: View {
    let logText: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Simulation Log")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background(Color(NSColor.controlBackgroundColor))
            
            ScrollViewReader { proxy in
                ScrollView {
                    Text(logText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id("logEnd")
                }
                .onChange(of: logText) { _, _ in
                    proxy.scrollTo("logEnd", anchor: .bottom)
                }
            }
        }
    }
}
