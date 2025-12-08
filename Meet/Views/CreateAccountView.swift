import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var communicationMethod = ""
    @State private var job = ""
    @State private var selectedGender = "Male"
    
    @State private var isCreating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let genders = ["Male", "Female"]
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text(strings.createAccount)
                        .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 28) : .title)
                        .fontWeight(.semibold)
                        .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        // Name
                        TextField(strings.name, text: $name)
                            .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .multilineTextAlignment(localizationManager.isArabic ? .trailing : .leading)
                        
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
                        
                        // Communication Method
                        TextField(strings.communicationMethod, text: $communicationMethod)
                            .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .multilineTextAlignment(localizationManager.isArabic ? .trailing : .leading)
                        
                        // Job
                        TextField(strings.job, text: $job)
                            .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .multilineTextAlignment(localizationManager.isArabic ? .trailing : .leading)
                        
                        // Gender Picker
                        VStack(alignment: localizationManager.isArabic ? .trailing : .leading, spacing: 8) {
                            Text(strings.gender)
                                .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                .fontWeight(.medium)
                            
                            Picker("", selection: $selectedGender) {
                                Text(strings.male).tag("Male")
                                Text(strings.female).tag("Female")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 40)
                    
                    // Sign Up Button
                    Button(action: createAccount) {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(strings.signUp)
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
                    .padding(.top, 20)
                    .disabled(isCreating)
                    
                    // Already have account
                    HStack {
                        Text(strings.alreadyHaveAccount)
                            .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 15) : .footnote)
                            .foregroundColor(.gray)
                        Button(action: { dismiss() }) {
                            Text(strings.login)
                                .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 15) : .footnote)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.7, green: 0.85, blue: 0.85))
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func createAccount() {
        guard !name.isEmpty, !phoneNumber.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all required fields"
            showError = true
            return
        }
        
        isCreating = true
        
        authService.register(
            name: name,
            phoneNumber: phoneNumber,
            password: password,
            communicationMethod: communicationMethod,
            job: job,
            gender: selectedGender
        ) { result in
            isCreating = false
            
            switch result {
            case .success:
                // Registration successful - HomeView will show automatically
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    CreateAccountView()
        .environmentObject(AuthService())
        .environmentObject(LocalizationManager())
}
