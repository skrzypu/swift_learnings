//
//  APODItemView.swift
//  AAPODAI
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct APODItemFeature {
    @ObservableState
    struct State: Equatable {
        let item: APODItem
        var viewed = false
    }

    enum Action {
        case viewed
        case opened
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .opened:
                return .run { [state] send in
                    @Dependency(\.analyticsService) var analyticsService
                    await analyticsService.logAPODItemOpened(item: state.item)
                }
            case .viewed:
                guard !state.viewed else {
                    return .none
                }
                state.viewed = true
                return .run { [state] send in
                    @Dependency(\.analyticsService) var analyticsService
                    await analyticsService.logAPODItemShowed(item: state.item)
                }
            }
        }
    }
}

struct APODItemView: View {
    @Bindable var store: StoreOf<APODItemFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.item.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            Text("Date: \(store.item.date)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Check if the media type is image and display thumbnail
            if store.item.media_type == .image, let imageURL = URL(string: store.item.url) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView() // Show a loading indicator
                }
            }
            
            Text(store.item.explanation)
                .font(.body)
                .lineLimit(3) // Limit explanation to 3 lines in the list view
                .foregroundColor(.primary)
            
            // Display tags as chips
            if let tags = store.item.tags {
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
    }
}
