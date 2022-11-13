import SwiftUI
import UIKit
import ComposableArchitecture

struct AppReducer: ReducerProtocol {
    
    struct State: Equatable {
        var linuxClipboard = ClipboardReducer.State()
        var macOSClipboard = ClipboardReducer.State()
    }
    
    enum Action {
        case linuxClipboardAction(ClipboardReducer.Action)
        case macOSClipboardAction(ClipboardReducer.Action)
    }
 
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.linuxClipboard, action: /Action.linuxClipboardAction) {
            ClipboardReducer()
        }
        Scope(state: \State.macOSClipboard, action: /Action.macOSClipboardAction) {
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
                Text("let's get you set up")
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.5)
                    .font(.title)
                    .bold()
                    .truncationMode(.middle)
                Button(action: { }, label: {
                    Image("computer")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .stretch)
                        .scaledToFit()
                        .frame(minWidth: 300,
                               idealWidth: 300, 
                               maxWidth: .infinity,
                               minHeight: 150, 
                               idealHeight: 300,
                               maxHeight: .infinity, 
                               alignment: .center
                        )
                })
                Text("How to install:")
                    .foregroundColor(.black)
                    .font(.largeTitle)
                    .bold()
                    .truncationMode(.middle)
                Text("""
                 1. Copy install script below
                 2. Paste on your terminal
                 3. Hit return; and let it install
                 4. Get cool terminal features such as:
                    • Autocompletion
                    • Swift
                    • Git
                    • Code review tools
                    • neovim and tmux theme 
                """)
                .foregroundColor(.black)
                .frame(minHeight: 250)
                .font(.title3)
                .bold()
                Clipboard(
                    title: "Alipine Linux & Ubuntu", 
                    content: "wget https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer; chmod +x installer; ./installer", 
                    store: self.store.scope(state: \.linuxClipboard, action: AppReducer.Action.linuxClipboardAction)
                )
                Clipboard(
                    title: "macOS", 
                    content: "bash <(curl -s https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer)", 
                    store: self.store.scope(state: \.macOSClipboard, action: AppReducer.Action.macOSClipboardAction)
                )
            }
        }
    }
}

struct ClipboardReducer: ReducerProtocol {
    struct State: Equatable {
        var symbol = Symbol.squares
        var remainingSeconds = 0.0
        let waitTime = 2.0
    }
    
    enum Action {
        case noop
        case reset
        case copyToClipboard(String)
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
        case .copyToClipboard(let content):
            state.symbol = .checkmark
            state.remainingSeconds = state.remainingSeconds + state.waitTime
            UIPasteboard.general.string = content
            let waitTime = state.waitTime
            return .task { [waitTime] in
                try await Task.sleep(for: .seconds(waitTime))
                return .reset
            }.animation(.easeInOut)
        }
    }
}

struct Clipboard: View {
    
    let title: String
    let content: String
    let store: StoreOf<ClipboardReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Button(action: { viewStore.send(.copyToClipboard(content) ) }) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(title)
                        .foregroundColor(.black)
                        .bold()
                    HStack {
                        TextField("🍌", // the banana is not expected to appear
                                  text: viewStore.binding(
                                    get: { _ in content },
                                    send: ClipboardReducer.Action.noop
                                  )
                        )
                        .disabled(true)
                        .onTapGesture {
                            viewStore.send(.copyToClipboard(content))
                        }
                        .accentColor(.black)
                        .foregroundColor(.black)
                        Button(action: { viewStore.send(.copyToClipboard(content)) }) {
                            Image(systemName: viewStore.state.symbol.rawValue)
                                .accentColor(.black)
                        }
                    }
                    .padding(16)
                    .border(.black, width: 1)
                }
            }
            .frame(
                minWidth: 300,
                maxWidth: 400,
                maxHeight: .infinity,
                alignment: .center
            )
            .padding(20)
        }
    }
}
