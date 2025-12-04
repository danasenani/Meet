import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var authService: AuthService
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var communicationMethod = ""
    @State private var selectedJob = "Student"
    @State private var selectedGender = "Male"
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    let jobs = ["Student", "Teacher", "Engineer", "Doctor", "Designer", "Other"]
    let genders = ["Male", "Female"]
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Let's Meet!")
                        .font(.system(size: 32, weight: .semibold))
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                    
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        TextField("", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 40)
                    
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
                    
                    // Communication Method Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Communication Method")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        TextField("", text: $communicationMethod)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 40)
                    
                    // Job and Gender Dropdowns
                    HStack(spacing: 16) {
                        // Job Dropdown
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Job")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Menu {
                                ForEach(jobs, id: \.self) { job in
                                    Button(job) {
                                        selectedJob = job
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedJob)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                        }
                        
                        // Gender Dropdown
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Menu {
                                ForEach(genders, id: \.self) { gender in
                                    Button(gender) {
                                        selectedGender = gender
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedGender)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Create Account Button
                    Button(action: createAccount) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Create Account")
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
                    
                    // Login Link
                    HStack {
                        Text("Have an Account?")
                            .foregroundColor(.gray)
                        NavigationLink("Login", destination: LoginView())
                            .foregroundColor(.black)
                    }
                    .font(.system(size: 14))
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func createAccount() {
        // Validation
        guard !name.isEmpty, !phoneNumber.isEmpty, !password.isEmpty, !communicationMethod.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        isLoading = true
        
        authService.register(
            name: name,
            phoneNumber: phoneNumber,
            password: password,
            communicationMethod: communicationMethod,
            job: selectedJob,
            gender: selectedGender
        ) { result in
            isLoading = false
            
            switch result {
            case .success:
                print("✅ Registration successful")
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
