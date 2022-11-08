import SwiftUI
import UIKit
import ComposableArchitecture

struct AppReducer: ReducerProtocol {
    
    struct State: Equatable {
        var installScript = "wget https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer; chmod +x installer; ./installer"
        var symbol = Symbol.squares
        var remainingSeconds = 0.0
        let waitTime = 2.0
        
        enum Symbol: String {
            case squares = "square.on.square"
            case checkmark = "checkmark"
        }
    }
    
    enum Action {
        case noop
        case reset
        case copyToClipboard
    }
 
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .noop:
            return .none
        case .reset:
            state.remainingSeconds -= state.waitTime    
            if state.remainingSeconds <= state.waitTime {
                state.symbol = .squares
            }
            return .none
        case .copyToClipboard:
            state.symbol = .checkmark
            state.remainingSeconds = state.remainingSeconds + state.waitTime
            UIPasteboard.general.string = state.installScript
            let waitTime = state.waitTime
            return .task { [waitTime] in
                try await Task.sleep(for: .seconds(waitTime))
                return .reset
            }.animation(.easeInOut)
        }
    }
}

struct RootView: View {
    
    let store: StoreOf<AppReducer> 
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color(.displayP3,
                      red: 238.0/255.0,
                      green: 189.0/255.0,
                      blue: 64.0/255.0,
                      opacity: 1.0
                )
                VStack(alignment: .center, spacing: 20) {
                    Text(".dotfiles installation")
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.3)
                        .font(.title)
                        .bold()
                        .truncationMode(.middle)
                    Button(action: { viewStore.send(.copyToClipboard) }, label: {
                        Image("relaxed")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .stretch)
                            .scaledToFit()
                            .frame(minWidth: 0,
                                   idealWidth: 300, 
                                   maxWidth: .infinity,
                                   minHeight: 100, 
                                   idealHeight: 300,
                                   maxHeight: .infinity, 
                                   alignment: .center
                            )
                    })
                    Text("copy, paste; have fun!")
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.3)
                        .font(.largeTitle)
                        .bold()
                        .truncationMode(.middle)
                    Text("""
                         1. Copy install script below
                         2. Paste on your terminal
                         3. Hit return; and let it install
                         4. Get all terminal features
                         """)
                        .foregroundColor(.black)
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    Button(action: { viewStore.send(.copyToClipboard) }) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Alpine Linux & Ubuntu")
                                .foregroundColor(.black)
                                .bold()
                            HStack {
                                TextField("🍌", // the banana is not expected to appear
                                          text: viewStore.binding(
                                            get: { $0.installScript },
                                            send: AppReducer.Action.noop
                                          )
                                )
                                .disabled(true)
                                .onTapGesture {
                                    viewStore.send(.copyToClipboard)
                                }
                                .accentColor(.black)
                                .foregroundColor(.black)
                                Button(action: { viewStore.send(.copyToClipboard) }) {
                                    Image(systemName: viewStore.state.symbol.rawValue)
                                        .accentColor(.black)
                                }
                            }
                            .padding(20)
                            .border(.black, width: 1)
                        }
                    }
                    .frame(
                        minWidth: 50.0,
                        idealWidth: 100,
                        maxWidth: 300,
                        minHeight: 44.0,
                        idealHeight: 44.0,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                }
            }
        }
    }
}

// TODO: Move Alpine linux here...
//struct CopySection: View {
//    var body: some View {}
//}
