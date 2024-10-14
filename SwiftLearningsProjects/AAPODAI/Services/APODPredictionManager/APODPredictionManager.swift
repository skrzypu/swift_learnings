//
//  APODPredictionManager.swift
//  AAPODAI
//

import Foundation

final class APODPredictionManager {
    private let model: APODLLM
    
    // A list of all possible tags based on the training data
    // WARNING: In this version each time tags will be changed in model this need be updated.
    enum Tags: String, CaseIterable {
        case meteor
        case exoplanet
        case supernova
        case galaxy
        case planet
        case nebula
        case comet
        case blackHole = "black hole"
        case star
        case eclipse
    }

    init() {
        guard let model = try? APODLLM(configuration: .init()) else {
            fatalError("Failed to load model")
        }
        self.model = model
    }

    // Convert tags into dummy variables (one-hot encoding)
    private func encodeTags(_ item: APODItem) -> [Tags: Double] {
        let itemTags = item.tags ?? []
        return Tags.allCases.reduce(into: [Tags: Double]()) { partialResult, tag in
            partialResult[tag] = itemTags.contains(tag.rawValue) ? 1.0 : 0.0
        }
    }

    // Method to predict the probability that a user will open an APOD item
    func predictOpenProbability(for item: APODItem) async throws -> Double {
        // Convert media type to dummy variable: 0 for image, 1 for video
        let mediaTypeValue = item.media_type == .image ? 0.0 : 1.0
        
        // One-hot encode tags
        let encodedTags = encodeTags(item)
        
        // Create input for the CoreML model
        let input = APODLLMInput(
            media_type_video: mediaTypeValue,
            black_hole: encodedTags[.blackHole, default: 0],
            comet: encodedTags[.comet, default: 0],
            eclipse: encodedTags[.eclipse, default: 0],
            exoplanet: encodedTags[.exoplanet, default: 0],
            galaxy: encodedTags[.galaxy, default: 0],
            meteor: encodedTags[.meteor, default: 0],
            nebula: encodedTags[.nebula, default: 0],
            planet: encodedTags[.planet, default: 0],
            star: encodedTags[.star, default: 0],
            supernova: encodedTags[.supernova, default: 0]
        )

        // Get the prediction asynchronously
        let prediction = try await model.prediction(input: input)
        
        // Return the predicted probability for class "1" (likely to be opened)
        return prediction.classProbability[1] ?? 0.0
    }

    // Method to sort APOD items by their predicted open probability using concurrent processing
    func sortItemsByOpenProbability(_ items: [APODItem]) async throws -> [APODItem] {
        var itemsWithProbabilities: [(index: Int, item: APODItem, probability: Double)] = []

        // Create a task group to process items concurrently
        try await withThrowingTaskGroup(of: (Int, APODItem, Double).self) { group in
            for (index, item) in items.enumerated() {
                group.addTask {
                    // Each task will predict the probability for an item
                    let probability = try await self.predictOpenProbability(for: item)
                    return (index, item, probability)
                }
            }

            // Collect results from the concurrent tasks
            for try await result in group {
                itemsWithProbabilities.append(result)
            }
        }

        // Sort items based on probability, highest to lowest, maintaining original order if probabilities are equal
        let sortedItems = itemsWithProbabilities
            .sorted {
                if $0.probability == $1.probability {
                    return $0.index < $1.index // Maintain original order when probabilities are equal
                } else {
                    return $0.probability > $1.probability
                }
            }
            .map { $0.item }

        return sortedItems
    }
}
