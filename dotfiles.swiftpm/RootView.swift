import SwiftUI
import UIKit
import ComposableArchitecture

struct AppReducer: ReducerProtocol {
    
    struct State: Equatable {
        var clipboard1 = ClipboardReducer.State(installScript: "wget https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer; chmod +x installer; ./installer")
        var clipboard2 = ClipboardReducer.State(installScript: "bash <(curl -s https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer)")
    }
    
    enum Action {
        case clipboard1Action(ClipboardReducer.Action)
        case clipboard2Action(ClipboardReducer.Action)
    }
 
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.clipboard1, action: /Action.clipboard1Action) {
            ClipboardReducer()
        }
        Scope(state: \State.clipboard2, action: /Action.clipboard2Action) {
            ClipboardReducer()
        }
    }
}

struct RootView: View {
    
    let store: StoreOf<AppReducer> 
    
    var body: some View {
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
                Button(action: {  }, label: {
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
                Text("I like dotfiles and I cannot lie!")
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
                CopySection(title: "Alipine Linux & Ubuntu", store: self.store.scope(state: \.clipboard1, action: AppReducer.Action.clipboard1Action))
                CopySection(title: "macOS", store: self.store.scope(state: \.clipboard2, action: AppReducer.Action.clipboard2Action))
            }
        }
    }
}

struct ClipboardReducer: ReducerProtocol {
    struct State: Equatable {
        var symbol = Symbol.squares
        var remainingSeconds = 0.0
        let installScript: String  
        let waitTime = 2.0
        
        init(installScript: String) {
            self.installScript = installScript
        }
    }
    
    enum Action {
        case noop
        case reset
        case copyToClipboard
    }
    
    enum Symbol: String {
        case squares = "square.on.square"
        case checkmark = "checkmark"
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

struct CopySection: View {
    
    let title: String
    let store: StoreOf<ClipboardReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Button(action: { viewStore.send(.copyToClipboard) }) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(title)
                        .foregroundColor(.black)
                        .bold()
                    HStack {
                        TextField("🍌", // the banana is not expected to appear
                                  text: viewStore.binding(
                                    get: { $0.installScript },
                                    send: ClipboardReducer.Action.noop
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
