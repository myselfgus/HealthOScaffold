// TrainTranscriptNormalizer.swift
// Create ML training pipeline for HealthOS transcript normalization.
//
// Run (requires macOS with Create ML framework):
//   swift TrainTranscriptNormalizer.swift
//
// Output: TranscriptNormalizer.mlmodel → copy to
//   swift/Sources/HealthOSProviders/Resources/TranscriptNormalizer.mlmodel
// Then enable via HealthOSProviders/ModelGovernance with explicit operator approval.
//
// SCAFFOLD: training data, validation split, and model spec are placeholders.
// Real training requires annotated transcript pairs (raw → normalized).
// No model ships without ModelGovernance approval and provenance record.

import Foundation
import CreateML

// Training data schema:
// Input:  raw transcript text (speech-to-text output, unnormalized)
// Output: normalized transcript text (corrected medical terminology, punctuation)
//
// Example pair:
//   raw:        "paciente relata dor de cabeca insoniar e piora do sono ha uma semana"
//   normalized: "Paciente relata dor de cabeça, insônia e piora do sono há uma semana."

struct TranscriptPair: Codable {
    let raw: String
    let normalized: String
}

// SCAFFOLD: replace with real annotated data loader
func loadTrainingData() throws -> MLDataTable {
    // Placeholder — real data must be loaded from a governed, de-identified corpus.
    // Data must not contain real patient identifiers (CPF, name, DOB).
    // Provenance record required before training.
    fatalError("SCAFFOLD: provide annotated transcript pairs before training")
}

// SCAFFOLD: adjust parameters after baseline experiments
let modelParameters = MLTextClassifier.ModelParameters(
    validation: .split(strategy: .automatic),
    maxIterations: 10,
    algorithm: .transferLearning(
        featureExtractor: .elmoEmbeddings,
        classifier: .maximumEntropy(options: .init())
    )
)

do {
    let trainingData = try loadTrainingData()
    let model = try MLTextClassifier(
        trainingData: trainingData,
        targetColumn: "normalized",
        textColumn: "raw",
        parameters: modelParameters
    )
    let outputURL = URL(fileURLWithPath: "TranscriptNormalizer.mlmodel")
    try model.write(to: outputURL)
    print("Model written to \(outputURL.path)")
    print("Copy to swift/Sources/HealthOSProviders/Resources/ and register with ModelGovernance.")
} catch {
    print("Training failed: \(error)")
    exit(1)
}
