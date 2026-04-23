import SwiftUI
import HealthOSCore

struct ScribeFirstSliceView: View {
    @Bindable var model: ScribeFirstSliceViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SurfaceSummaryCard(model: model)
                SessionSetupCard(model: model)
                WorkspaceCard(model: model)
                SliceOutputsCard(model: model)
                IssuesCard(model: model)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 860, minHeight: 760)
    }
}

private struct SurfaceSummaryCard: View {
    let model: ScribeFirstSliceViewModel

    var body: some View {
        GroupBox("Scribe First Slice Surface") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Superficie minima de validacao funcional. A UI consome a bridge do first slice e apenas mostra estado, gate e degradacao.")
                    .foregroundStyle(.secondary)

                LabeledContent("Professional token", value: model.professionalToken.isEmpty ? "pending" : model.professionalToken)
                LabeledContent("Service", value: model.serviceName.isEmpty ? "pending" : model.serviceName)
                LabeledContent("Session state", value: model.sessionState.rawValue)
                LabeledContent("Runtime health", value: model.runtimeHealth.rawValue)
                LabeledContent("Degraded mode", value: model.degradedMode.rawValue)
                LabeledContent("Last action", value: model.lastAction)
                if let disposition = model.lastDisposition {
                    LabeledContent("Last disposition", value: disposition.rawValue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct SessionSetupCard: View {
    @Bindable var model: ScribeFirstSliceViewModel

    var body: some View {
        GroupBox("1. Session Start") {
            VStack(alignment: .leading, spacing: 12) {
                Button("Open professional session") {
                    Task {
                        await model.startSession()
                    }
                }
                .disabled(!model.canStartSession)

                if let sessionId = model.sessionId {
                    LabeledContent("Session id", value: sessionId.uuidString)
                } else {
                    Text("Abra a sessao para habilitar selecao de paciente e captura seeded-text.")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct WorkspaceCard: View {
    @Bindable var model: ScribeFirstSliceViewModel

    var body: some View {
        GroupBox("2. Patient, Capture, Gate") {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Patient token", selection: $model.selectedPatientID) {
                    Text("Select a patient").tag(Optional<UUID>.none)
                    ForEach(model.availablePatients) { patient in
                        Text(patient.civilToken).tag(Optional(patient.id))
                    }
                }

                HStack {
                    Button("Select patient") {
                        Task {
                            await model.selectPatient()
                        }
                    }
                    .disabled(!model.canSelectPatient)

                    if let patient = model.selectedPatient {
                        Text("Current patient: \(patient.civilToken)")
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Capture text (seeded)")
                    TextEditor(text: $model.captureText)
                        .font(.body.monospaced())
                        .frame(minHeight: 120)
                }

                HStack {
                    Button("Submit capture") {
                        Task {
                            await model.submitCapture()
                        }
                    }
                    .disabled(!model.canSubmitCapture)

                    Button("Advance to draft preview") {
                        Task {
                            await model.requestDraftPreview()
                        }
                    }
                    .disabled(!model.canRequestDraftPreview)
                }

                HStack {
                    Button("Approve gate") {
                        Task {
                            await model.resolveGate(approve: true)
                        }
                    }
                    .disabled(!model.canResolveGate)

                    Button("Reject gate") {
                        Task {
                            await model.resolveGate(approve: false)
                        }
                    }
                    .disabled(!model.canResolveGate)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct SliceOutputsCard: View {
    let model: ScribeFirstSliceViewModel

    var body: some View {
        GroupBox("3. Slice Outputs") {
            VStack(alignment: .leading, spacing: 14) {
                OutputBlock(title: "Transcript preview", text: model.bridgeState?.transcriptPreview ?? "Nenhuma captura submetida ainda.")
                OutputBlock(
                    title: "Retrieval summary",
                    text: retrievalText
                )
                OutputBlock(title: "Draft preview", text: model.bridgeState?.draftPreview ?? "Nenhum draft visivel ainda.")

                LabeledContent("Draft state", value: model.bridgeState?.draftState.rawValue ?? "empty")
                LabeledContent("Gate state", value: model.bridgeState?.gateState.rawValue ?? "none")
                LabeledContent("Final summary", value: model.finalSummaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var retrievalText: String {
        guard let retrieval = model.bridgeState?.retrieval else {
            return "Nenhum retrieval executado ainda."
        }

        let preview = retrieval.previewItems.isEmpty
            ? "sem itens ainda"
            : retrieval.previewItems.joined(separator: "\n")
        return [
            "status: \(retrieval.status.rawValue)",
            "source: \(retrieval.source)",
            "matches: \(retrieval.matchCount)",
            preview
        ]
        .joined(separator: "\n")
    }
}

private struct IssuesCard: View {
    let model: ScribeFirstSliceViewModel

    var body: some View {
        GroupBox("4. Issues / Degraded / Deny") {
            if model.issues.isEmpty {
                Text("Nenhum issue ativo no momento.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(model.issues.enumerated()), id: \.offset) { _, issue in
                        Text(issueLine(issue))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private func issueLine(_ issue: HealthOSIssue) -> String {
        if let failureKind = issue.failureKind {
            return "\(issue.code.rawValue) [\(failureKind.rawValue)] \(issue.message)"
        }
        return "\(issue.code.rawValue) \(issue.message)"
    }
}

private struct OutputBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(text)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
