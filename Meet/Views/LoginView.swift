import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text(strings.login)
                    .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 28) : .title)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    // Phone Number
                    TextField(strings.phoneNumber, text: $phoneNumber)
                        .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .multilineTextAlignment(localizationManager.isArabic ? .trailing : .leading)
                    
                    // Password
                    SecureField(strings.password, text: $password)
                        .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                // Login Button
                Button(action: login) {
                    if isLoggingIn {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(strings.login)
                            .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color(red: 0.7, green: 0.85, blue: 0.85))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .disabled(isLoggingIn)
                
                Spacer()
                
                // Back to Join
                Button(action: { dismiss() }) {
                    Text(strings.join)
                        .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 15) : .footnote)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func login() {
        guard !phoneNumber.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields"
            showError = true
            return
        }
        
        isLoggingIn = true
        
        authService.login(phoneNumber: phoneNumber, password: password) { result in
            isLoggingIn = false
            
            switch result {
            case .success:
                // Login successful - HomeView will show automatically
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
        .environmentObject(LocalizationManager())
}
