import Foundation

public enum ModelRegistryStatus: String, Codable, Sendable {
    case draft
    case evaluated
    case promoted
    case deprecated
    case revoked
}

public struct ModelRegistryEntry: Codable, Sendable, Equatable {
    public let modelId: String
    public let providerId: String
    public let modelName: String
    public let modelVersion: String
    public let taskClass: ProviderTaskClass
    public let providerKind: ProviderKind
    public let status: ModelRegistryStatus
    public let evaluationRefs: [String]
    public let adapterRefs: [String]
    public let dataGovernanceClass: String
    public let provenanceRequirements: [String]
    public let promotionNotes: String?
    public let rollbackNotes: String?
    public let isTemplate: Bool

    public init(
        modelId: String,
        providerId: String,
        modelName: String,
        modelVersion: String,
        taskClass: ProviderTaskClass,
        providerKind: ProviderKind,
        status: ModelRegistryStatus,
        evaluationRefs: [String],
        adapterRefs: [String],
        dataGovernanceClass: String,
        provenanceRequirements: [String],
        promotionNotes: String? = nil,
        rollbackNotes: String? = nil,
        isTemplate: Bool = false
    ) {
        self.modelId = modelId
        self.providerId = providerId
        self.modelName = modelName
        self.modelVersion = modelVersion
        self.taskClass = taskClass
        self.providerKind = providerKind
        self.status = status
        self.evaluationRefs = evaluationRefs
        self.adapterRefs = adapterRefs
        self.dataGovernanceClass = dataGovernanceClass
        self.provenanceRequirements = provenanceRequirements
        self.promotionNotes = promotionNotes
        self.rollbackNotes = rollbackNotes
        self.isTemplate = isTemplate
    }
}

public enum ModelRegistryError: Error, Equatable, Sendable {
    case draftPromotionRequiresEvaluation
    case revokedModelNotSelectable
    case noEligibleModel
}

public actor ModelRegistry {
    private var entries: [String: ModelRegistryEntry] = [:]

    public init() {}

    public func register(_ entry: ModelRegistryEntry) {
        entries[entry.modelId] = entry
    }

    public func promote(modelId: String, notes: String) throws {
        guard let entry = entries[modelId] else { throw ModelRegistryError.noEligibleModel }
        guard !entry.evaluationRefs.isEmpty else {
            throw ModelRegistryError.draftPromotionRequiresEvaluation
        }
        entries[modelId] = ModelRegistryEntry(
            modelId: entry.modelId,
            providerId: entry.providerId,
            modelName: entry.modelName,
            modelVersion: entry.modelVersion,
            taskClass: entry.taskClass,
            providerKind: entry.providerKind,
            status: .promoted,
            evaluationRefs: entry.evaluationRefs,
            adapterRefs: entry.adapterRefs,
            dataGovernanceClass: entry.dataGovernanceClass,
            provenanceRequirements: entry.provenanceRequirements,
            promotionNotes: notes,
            rollbackNotes: entry.rollbackNotes,
            isTemplate: entry.isTemplate
        )
    }

    public func select(
        taskClass: ProviderTaskClass,
        includeDeprecated: Bool = false
    ) throws -> ModelRegistryEntry {
        let candidates = entries.values.filter { entry in
            guard entry.taskClass == taskClass else { return false }
            switch entry.status {
            case .revoked:
                return false
            case .deprecated:
                return includeDeprecated
            case .promoted:
                return true
            case .evaluated, .draft:
                return false
            }
        }
        if candidates.isEmpty {
            if entries.values.contains(where: { $0.taskClass == taskClass && $0.status == .revoked }) {
                throw ModelRegistryError.revokedModelNotSelectable
            }
            throw ModelRegistryError.noEligibleModel
        }
        return candidates.sorted { $0.modelVersion > $1.modelVersion }.first ?? candidates[0]
    }

    public func entry(modelId: String) -> ModelRegistryEntry? {
        entries[modelId]
    }
}

public struct DatasetVersion: Codable, Sendable, Equatable {
    public let datasetId: String
    public let version: String
    public let governanceMetadata: [String: String]

    public init(datasetId: String, version: String, governanceMetadata: [String: String]) {
        self.datasetId = datasetId
        self.version = version
        self.governanceMetadata = governanceMetadata
    }
}

public enum TrainingJobStatus: String, Codable, Sendable {
    case staged
    case running
    case completed
    case failed
}

public struct TrainingJobRecord: Codable, Sendable, Equatable {
    public let jobId: String
    public let datasetVersion: DatasetVersion
    public let baseModelId: String
    public let createdAt: Date
    public let status: TrainingJobStatus

    public init(jobId: String, datasetVersion: DatasetVersion, baseModelId: String, createdAt: Date = .now, status: TrainingJobStatus = .staged) {
        self.jobId = jobId
        self.datasetVersion = datasetVersion
        self.baseModelId = baseModelId
        self.createdAt = createdAt
        self.status = status
    }
}

public struct AdapterArtifact: Codable, Sendable, Equatable {
    public let adapterId: String
    public let jobId: String
    public let parentAdapterId: String?

    public init(adapterId: String, jobId: String, parentAdapterId: String? = nil) {
        self.adapterId = adapterId
        self.jobId = jobId
        self.parentAdapterId = parentAdapterId
    }
}

public struct EvaluationResult: Codable, Sendable, Equatable {
    public let evaluationId: String
    public let adapterId: String
    public let notes: String

    public init(evaluationId: String, adapterId: String, notes: String) {
        self.evaluationId = evaluationId
        self.adapterId = adapterId
        self.notes = notes
    }
}

public struct AdapterPromotionDecision: Codable, Sendable, Equatable {
    public let adapterId: String
    public let evaluationId: String
    public let promotedAt: Date

    public init(adapterId: String, evaluationId: String, promotedAt: Date = .now) {
        self.adapterId = adapterId
        self.evaluationId = evaluationId
        self.promotedAt = promotedAt
    }
}

public struct AdapterRollbackDecision: Codable, Sendable, Equatable {
    public let fromAdapterId: String
    public let toAdapterId: String
    public let note: String
    public let rolledBackAt: Date

    public init(fromAdapterId: String, toAdapterId: String, note: String, rolledBackAt: Date = .now) {
        self.fromAdapterId = fromAdapterId
        self.toAdapterId = toAdapterId
        self.note = note
        self.rolledBackAt = rolledBackAt
    }
}

public enum FineTuningGovernanceError: Error, Equatable, Sendable {
    case datasetVersionRequired
    case evaluationRequiredForPromotion
    case adapterNotFound
    case previousAdapterRequiredForRollback
}

public actor FineTuningGovernanceRegistry {
    private var jobs: [String: TrainingJobRecord] = [:]
    private var adapters: [String: AdapterArtifact] = [:]
    private var evaluations: [String: EvaluationResult] = [:]
    private var promotedAdapterId: String?

    public init() {}

    public func stageTrainingJob(jobId: String, datasetVersion: DatasetVersion?, baseModelId: String) throws -> TrainingJobRecord {
        guard let datasetVersion else {
            throw FineTuningGovernanceError.datasetVersionRequired
        }
        let job = TrainingJobRecord(jobId: jobId, datasetVersion: datasetVersion, baseModelId: baseModelId)
        jobs[jobId] = job
        return job
    }

    public func registerAdapter(_ adapter: AdapterArtifact) {
        adapters[adapter.adapterId] = adapter
    }

    public func registerEvaluation(_ evaluation: EvaluationResult) {
        evaluations[evaluation.evaluationId] = evaluation
    }

    public func promoteAdapter(adapterId: String, evaluationId: String?) throws -> AdapterPromotionDecision {
        guard adapters[adapterId] != nil else {
            throw FineTuningGovernanceError.adapterNotFound
        }
        guard let evaluationId, evaluations[evaluationId]?.adapterId == adapterId else {
            throw FineTuningGovernanceError.evaluationRequiredForPromotion
        }
        promotedAdapterId = adapterId
        return AdapterPromotionDecision(adapterId: adapterId, evaluationId: evaluationId)
    }

    public func rollback(to previousAdapterId: String?, note: String) throws -> AdapterRollbackDecision {
        guard let fromAdapterId = promotedAdapterId else {
            throw FineTuningGovernanceError.adapterNotFound
        }
        guard let previousAdapterId, adapters[previousAdapterId] != nil else {
            throw FineTuningGovernanceError.previousAdapterRequiredForRollback
        }
        promotedAdapterId = previousAdapterId
        return AdapterRollbackDecision(fromAdapterId: fromAdapterId, toAdapterId: previousAdapterId, note: note)
    }

    public func currentPromotedAdapterId() -> String? {
        promotedAdapterId
    }
}
