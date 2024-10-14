//
//  HomeView.swift
//  AAPODAI
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var items: [StoreOf<APODItemFeature>]
        var path = StackState<APODDetailFeature.State>()
    }
    
    enum Action {
        case path(StackAction<APODDetailFeature.State, APODDetailFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .path(.element(id: id,
                                    action: .delegate(.itemOpened))):
                guard let detailState = state.path[id: id],
                      let index = state.items.map(\.state.item).firstIndex(of: detailState.apodItem)
                        else { return .none }
                state.items[index].send(.opened)
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            APODDetailFeature()
        }
    }
}

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                LazyVStack {
                    ForEach(store.items, id: \.self) { item in
                        NavigationLink(state: APODDetailFeature.State(apodItem: item.item)) {
                            APODItemView(store: item)
                                .onAppear() {
                                    item.send(.viewed)
                                }
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .navigationTitle("APOD")
        } destination: { store in
            APODDetailView(store: store)
          }
    }
}

#Preview {
    NavigationStack {
        HomeView(store: Store(initialState: HomeFeature.State(items: APODServicePreview.items.map { item in
            Store(initialState: APODItemFeature.State(item: item)) {
                APODItemFeature()
            }
        })) {
            HomeFeature()
        }
        )
    }
}
