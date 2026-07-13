import SwiftUI

/// Paste one SKU per line, look them all up, and drop each result into the
/// print queue. Then Export PDF gang-runs the whole queue into one
/// print-ready file. Uses the current size / format / footer settings.
struct BulkLookupView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bulk Lookup")
                .font(.title3.bold())
            Text("One SKU per line. Each is looked up at store #\(UserDefaults.standard.string(forKey: Prefs.storeCode) ?? "12180") and added to the print queue with the current size and format. When it's done, Export PDF makes one file with every sign.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SKUs")
                        .font(.caption).foregroundColor(.secondary)
                    TextEditor(text: $state.bulkText)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 200)
                        .border(Color.secondary.opacity(0.3))
                        .disabled(state.isBulkRunning)
                    Text("\(state.bulkSKUs.count) SKU\(state.bulkSKUs.count == 1 ? "" : "s")")
                        .font(.caption).foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Results")
                        .font(.caption).foregroundColor(.secondary)
                    resultsList
                }
            }

            if state.isBulkRunning {
                ProgressView(value: Double(state.bulkDone), total: Double(max(state.bulkTotal, 1))) {
                    Text("Looking up \(state.bulkDone) of \(state.bulkTotal)…")
                        .font(.callout)
                }
            }

            HStack {
                Button("Look Up All (\(state.bulkSKUs.count))") { state.runBulkLookup() }
                    .buttonStyle(.borderedProminent)
                    .disabled(state.isBulkRunning || state.bulkSKUs.isEmpty)

                if !state.queue.isEmpty {
                    Button {
                        state.exportQueuePDF()
                    } label: {
                        Label("Export PDF (\(state.queue.count))", systemImage: "square.and.arrow.down")
                    }
                    .disabled(state.isBulkRunning)
                    Button("Print") { state.printQueue() }
                        .disabled(state.isBulkRunning)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(state.isBulkRunning)
            }

            if !state.queue.isEmpty {
                Text(state.queuePlanDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(width: 620, height: 480)
    }

    private var resultsList: some View {
        ScrollViewReader { proxy in
            List(state.bulkLog) { entry in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Image(systemName: entry.ok ? "checkmark.circle.fill" : "minus.circle")
                        .foregroundColor(entry.ok ? .green : .secondary)
                    Text(entry.sku).fontWeight(.medium)
                    Text(entry.detail)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .font(.callout)
                .id(entry.id)
            }
            .border(Color.secondary.opacity(0.3))
            .onChange(of: state.bulkLog.count) { _ in
                if let last = state.bulkLog.last { proxy.scrollTo(last.id) }
            }
        }
    }
}
