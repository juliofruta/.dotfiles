import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
    var body: some Scene {
      WindowGroup {
        RootView(
          store: 
              Store(
                 initialState: AppReducer.State(),
                 reducer: AppReducer()
              )
        )
      }
    }
}
