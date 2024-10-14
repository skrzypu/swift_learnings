//
//  ContentView.swift
//  AAPODAI
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct InitialisationFeature {
    @ObservableState
    struct State: Equatable {
        var loading: Bool = true
        var items: [APODItem] = []
    }

    enum Action {
        case loadItems
        case itemsLoaded([APODItem])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
          switch action {
          case .loadItems:
              return .run { send in
                  do {
                      @Dependency(\.apodService) var apodService
                      let apodItems = try await apodService.loadItems()
                      await send(
                        .itemsLoaded(apodItems)
                      )
                  } catch {
                      print(error)
                  }
            }
          case let .itemsLoaded(items):
              state.items = items
              state.loading = false
            return .none
          }
        }
      }
}

struct ContentView: View {
    let store: StoreOf<InitialisationFeature> = Store(initialState: InitialisationFeature.State()) {
        InitialisationFeature()
      }

    var body: some View {
        if store.loading {
            SplashView()
                .padding()
                .onAppear() {
                    store.send(.loadItems)
                }
        } else {
            NavigationView {
                HomeView(store: Store(initialState: HomeFeature.State(items: store.items.map {
                    Store(initialState: APODItemFeature.State(item: $0)) {
                        APODItemFeature()
                    }
                })) {
                    HomeFeature()
                  }
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
