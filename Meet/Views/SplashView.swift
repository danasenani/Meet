import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo/Image
                    Image(systemName: "cup.and.saucer.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                    
                    Text("Let's Meet!")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Join Button
                        NavigationLink(destination: CreateAccountView()
                            .environmentObject(authService)) {
                            Text("Join")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 0.95, green: 0.7, blue: 0.7))
                                .cornerRadius(25)
                        }
                        
                        // Login Button
                        NavigationLink(destination: LoginView()
                            .environmentObject(authService)) {
                            Text("Login")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AuthService())
}

