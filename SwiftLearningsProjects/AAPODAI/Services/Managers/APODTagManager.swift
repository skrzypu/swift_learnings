//
//  APODTagManager.swift
//  AAPODAI
//

import Foundation
import NaturalLanguage
import ComposableArchitecture

// Class-based APODManager to generate tags
final class APODTagManager {
    
    // List of stopwords
    private let stopwords: Set<String> = ["the", "is", "and", "in", "of", "to", "a", "on", "for", "with", "this", "that", "it", "by", "as", "sir"]
    
    // Async function to generate ranked tags for a single APODItem
    func generateRankedTags(from explanation: String) -> [String] {
        var tagFrequency: [String: Int] = [:]
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = explanation
        
        // Set the language of the text for the tagger
        tagger.setLanguage(.english, range: explanation.startIndex..<explanation.endIndex)
        
        let range = explanation.startIndex..<explanation.endIndex

        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: [.omitPunctuation, .omitWhitespace, .omitOther]) { tag, tokenRange in
            // For debugging: Print each word and tag
            let word = String(explanation[tokenRange]).lowercased()

            // Guard for short words or stopwords
            guard word.count >= 3, !self.stopwords.contains(word) else {
                return true
            }

            // Use switch-case to accumulate tag frequencies directly
            switch tag {
            case .personalName, .placeName, .organizationName:
                tagFrequency[word, default: 0] += 3 // Boost for named entities
            case .otherWord:
                tagFrequency[word, default: 0] += 1
            default:
                break
            }

            return true
        }

        // Sort and take the top 4 tags
        let rankedTags = tagFrequency.sorted(by: { $0.value > $1.value }).prefix(4).map { $0.key }
        return Array(rankedTags)
    }
    
    // Function to assign tags to multiple APODItems concurrently
    func assignTagsToItems(_ items: [APODItem]) async -> [APODItem] {
        var updatedItems = items // Create a mutable copy to store updated items

        await withTaskGroup(of: (Int, [String]).self) { group in
            for i in items.indices {
                group.addTask {
                    let tags = self.generateRankedTags(from: items[i].explanation)
                    return (i, tags) // Return the index and tags
                }
            }

            for await (index, tags) in group { // Update the items with the returned tags
                updatedItems[index].tags = tags
            }
        }

        return updatedItems // Return the updated items
    }
}

extension APODTagManager: DependencyKey {
  static let liveValue = APODTagManager()
}

extension DependencyValues {
  var tagManager: APODTagManager {
    get { self[APODTagManager.self] }
    set { self[APODTagManager.self] = newValue }
  }
}
