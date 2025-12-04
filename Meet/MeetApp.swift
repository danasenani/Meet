import SwiftUI
import FirebaseCore

@main
struct MeetApp: App {
    @StateObject private var authService = AuthService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated && authService.currentUser != nil {
                    HomeView()
                        .environmentObject(authService)
                } else {
                    SplashView()
                        .environmentObject(authService)
                }
            }
        }
    }
}
