import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
   
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("Let's Meet!")
                    .font(.system(size: 32, weight: .semibold))
                    .padding(.bottom, 40)
                
                // Phone Number Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    TextField("", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    SecureField("", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                
                // Login Button
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    } else {
                        Text("Login")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .background(Color(red: 0.95, green: 0.7, blue: 0.7))
                .cornerRadius(25)
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .disabled(isLoading)
                
                // Create Account Link
                HStack {
                    Text("New?")
                        .foregroundColor(.gray)
                    NavigationLink("Create Account", destination: CreateAccountView())
                        .foregroundColor(.black)
                }
                .font(.system(size: 14))
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        
    }
    
    func login() {
        guard !phoneNumber.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        
        authService.login(phoneNumber: phoneNumber, password: password) { result in
            isLoading = false
            
            switch result {
            case .success:
                // User is now fully loaded, navigation will happen automatically
                print("✅ Login successful")
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    LoginView()
}
