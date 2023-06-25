import SwiftUI
import ComposableArchitecture
import UserNotifications

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
      WindowGroup {
        RootView(
          store: 
              Store(
                 initialState: AppReducer.State(),
                 reducer: AppReducer()
              )
        ).onAppear(perform: {
            print("appeared xd")
//            if !UIApplication.shared.isRegisteredForRemoteNotifications {
                UIApplication.shared.registerForRemoteNotifications()    
//            }
        })
      }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("got token!")
        print(String(data: deviceToken, encoding: .utf8)!)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to get token")
        print(error.localizedDescription)
    }
    
}
