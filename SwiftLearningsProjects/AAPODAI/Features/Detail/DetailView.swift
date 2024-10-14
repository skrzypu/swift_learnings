//
//  Detail.swift
//  AAPODAI
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct APODDetailFeature {
  @ObservableState
  struct State: Equatable {
    let apodItem: APODItem
  }
  enum Action {
      case delegate(Delegate)

      enum Delegate {
          case itemOpened
      }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
        .none
    }
  }
}

struct APODDetailView: View {
    let store: StoreOf<APODDetailFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Title
                Text(store.apodItem.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                // Date with icon
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text(store.apodItem.date)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Image or Video
                if store.apodItem.media_type == .image, let imageURL = URL(string: store.apodItem.url) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(.horizontal)
                } else if store.apodItem.media_type == .video {
                    // Placeholder for video
                    VStack {
                        Image(systemName: "video.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                
                // Explanation
                VStack(alignment: .leading, spacing: 10) {
                    Text("About this Image")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(store.apodItem.explanation)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                
                // Tags (displayed in a modern style)
                if !(store.apodItem.tags?.isEmpty ?? true) {
                    VStack(alignment: .leading) {
                        Text("Tags")
                            .font(.headline)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(store.apodItem.tags ?? [], id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(10)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("APOD Details")
        .onAppear() {
            store.send(.delegate(.itemOpened))
        }
    }
}

#Preview {
    NavigationStack {
        APODDetailView(store: Store(initialState: APODDetailFeature.State(apodItem: APODServicePreview.items[0])) {
            APODDetailFeature()
        }
        )
    }
}
