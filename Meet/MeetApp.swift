import SwiftUI
import FirebaseCore

@main
struct MeetApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var localizationManager = LocalizationManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                HomeView()
                    .environmentObject(authService)
                    .environmentObject(localizationManager)
                    .environment(\.layoutDirection, localizationManager.layoutDirection)
                    .environment(\.locale, .init(identifier: localizationManager.currentLanguage.rawValue))
            } else {
                SplashView()
                    .environmentObject(authService)
                    .environmentObject(localizationManager)
                    .environment(\.layoutDirection, localizationManager.layoutDirection)
                    .environment(\.locale, .init(identifier: localizationManager.currentLanguage.rawValue))
            }
        }
    }
}
