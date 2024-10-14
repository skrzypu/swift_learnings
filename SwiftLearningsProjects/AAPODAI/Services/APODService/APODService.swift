//
//  APODService.swift
//  AAPODAI
//

import Foundation
import ComposableArchitecture

//There is no network kit as I'm using only one service which should be pretty easy.


struct APODItem: Decodable {
    enum MediaType: String, Decodable {
        case image
        case video
        case other
    }
    let copyright: String?
    let date: String
    let explanation: String
    let hdurl: String?
    let media_type: MediaType
    let title: String
    let url: String

    var tags: [String]?
}

extension APODItem: Equatable {
    
}

protocol APODService {
    func loadItems() async throws -> [APODItem]
}

final class APODServiceImplements: APODService {
    private let predictionManager = APODPredictionManager()
    private let session = URLSession.shared
    //Move later to function to build query parameters
    private let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&count=20")!
    
    private let tagManager = APODTagManager()

    //We are using only one API which requires just key.
    //I'm trying new things with SwiftUI so I can make shortcuts
    func loadItems() async throws -> [APODItem] {
        let (data, response) = try await session.data(from: url)
        let decoder = JSONDecoder()
        let items = try decoder.decode([APODItem].self, from: data)
        let taggetItems = await tagManager.assignTagsToItems(items)
        let sortedItems = try await predictionManager.sortItemsByOpenProbability(taggetItems)
        return sortedItems
    }
}

final class APODServicePreview: APODService {
    let predictionManager = APODPredictionManager()

    static let items = {
        let tagManager = APODTagManager()
        let rawItems = [
            APODItem(
                copyright: "Chirag Upreti",
                date: "2021-06-04",
                explanation: "On May 26, the Full Flower Moon was caught in this single exposure as it emerged from Earth's shadow and morning twilight began to wash over the western sky. Posing close to the horizon near the end of totality, an eclipsed lunar disk is framed against bare oak trees at Pinnacles National Park in central California. The Earth's shadow isn't completely dark though. Faintly suffused with sunlight scattered by the atmosphere, the inner shadow gives the totally eclipsed moon a reddened appearance and the very dramatic popular moniker of a Blood Moon.",
                hdurl: "https://apod.nasa.gov/apod/image/2106/Lunareclipse_PinnaclesNationalPark.jpg",
                media_type: .image,
                title: "Blood Monster Moon",
                url: "https://apod.nasa.gov/apod/image/2106/Lunareclipse_PinnaclesNationalPark1024.jpg"
            ),
            APODItem(
                copyright: "Rainee Colacurcio",
                date: "2019-07-15",
                explanation: "That's no sunspot. It's the International Space Station (ISS) caught passing in front of the Sun. By contrast, the ISS is a complex and multi-spired mechanism, one of the largest and most sophisticated machines ever created by humanity. The picture combines two images: one capturing the space station transiting the Sun, and another taken consecutively capturing details of the Sun's surface.",
                hdurl: "https://apod.nasa.gov/apod/image/1907/SpotlessSunIss_Colacurcio_2048.jpg",
                media_type: .image,
                title: "The Space Station Crosses a Spotless Sun",
                url: "https://apod.nasa.gov/apod/image/1907/SpotlessSunIss_Colacurcio_960.jpg"
            ),
            APODItem(
                copyright: nil,
                date: "1996-07-07",
                explanation: "Sir Isaac Newton was born in 1643 and revolutionized our understanding of mathematics, gravitation, and optics. Newton's calculus provided a new mathematical framework for solving physical problems. Newton's law of gravitation explained how apples fall and planets move.",
                hdurl: "https://apod.nasa.gov/apod/image/IsaacNewton_big.jpg",
                media_type: .image,
                title: "Isaac Newton Explains the Solar System",
                url: "https://apod.nasa.gov/apod/image/IsaacNewton.gif"
            ),
            APODItem(
                copyright: nil,
                date: "2015-04-05",
                explanation: "Seen from ice moon Tethys, rings and shadows would display fantastic views of the Saturnian system. Tethys orbits around Saturn outside the main bright rings but is within the boundaries of the faint and tenuous outer E ring.",
                hdurl: "https://apod.nasa.gov/apod/image/1504/TethysRingShadow_cassini_1019.jpg",
                media_type: .image,
                title: "Saturn, Tethys, Rings, and Shadows",
                url: "https://apod.nasa.gov/apod/image/1504/TethysRingShadow_cassini_1080.jpg"
            )
        ]
        return rawItems.map {
            var item = $0
            item.tags = tagManager.generateRankedTags(from: item.explanation)
            return item
        }
    }()

    func loadItems() async throws -> [APODItem] {
        let sortedItems = try await predictionManager.sortItemsByOpenProbability(APODServicePreview.items)
        return sortedItems
    }
}

private enum APODServiceDependency: DependencyKey, TestDependencyKey {
    static let liveValue: APODService = APODServiceImplements()
    static let previewValue: APODService = APODServiceImplements() //APODServicePreview()
}

extension DependencyValues {
  var apodService: APODService {
    get { self[APODServiceDependency.self] }
    set { self[APODServiceDependency.self] = newValue }
  }
}
