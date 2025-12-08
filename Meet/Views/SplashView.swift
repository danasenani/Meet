import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var topHandOffset: CGFloat = -300
    @State private var bottomHandOffset: CGFloat = 300
    @State private var showContent = false
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Top hand with cup - slides in from top
                    Image("hand-cup-top")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 130)
                        .frame(maxWidth: .infinity, alignment: localizationManager.isArabic ? .trailing : .leading)
                        .offset(y: topHandOffset)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // "Let's Meet!" text - fades in
                    Text(strings.letsMeet)
                        .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 34) : .largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .opacity(showContent ? 1 : 0)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Bottom hand with cup - slides in from bottom
                    Image("hand-cup-bottom")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 130)
                        .frame(maxWidth: .infinity, alignment: localizationManager.isArabic ? .leading : .trailing)
                        .offset(y: bottomHandOffset)
                    
                    Spacer()
                    
                    // Buttons - fade in
                    VStack(spacing: 16) {
                        // Join Button
                        NavigationLink(destination: CreateAccountView()
                            .environmentObject(authService)
                            .environmentObject(localizationManager)) {
                            Text(strings.join)
                                .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.95, green: 0.7, blue: 0.7))
                                .cornerRadius(25)
                        }
                        
                        // Login Button
                        NavigationLink(destination: LoginView()
                            .environmentObject(authService)
                            .environmentObject(localizationManager)) {
                            Text(strings.login)
                                .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                    .opacity(showContent ? 1 : 0)
                }
            }
            .onAppear {
                // Animate hands sliding in
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    topHandOffset = 0
                    bottomHandOffset = 0
                }
                
                // Fade in text and buttons slightly after
                withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                    showContent = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AuthService())
        .environmentObject(LocalizationManager())
}
