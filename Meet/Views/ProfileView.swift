import SwiftUI
import FirebaseFirestore
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedCommunicationMethod = ""
    @State private var editedJob = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    let jobs = ["Student", "Teacher", "Engineer", "Doctor", "Designer", "Other"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Profile")
                            .font(.system(size: 28, weight: .semibold))
                            .padding(.top, 20)
                        
                        // Profile Picture
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            )
                            .padding(.top, 20)
                        
                        if let user = authService.currentUser {
                            // User Info Fields
                            VStack(spacing: 16) {
                                // Name (Editable)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Name")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    if isEditing {
                                        TextField("", text: $editedName)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(8)
                                    } else {
                                        Text(user.name)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                    }
                                }
                                
                                // Phone Number (Read-only)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Phone Number")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    Text(user.phoneNumber)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(8)
                                }
                                
                                // Communication Method (Editable)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Communication Method")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    if isEditing {
                                        TextField("", text: $editedCommunicationMethod)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(8)
                                    } else {
                                        Text(user.communicationMethod)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                    }
                                }
                                
                                // Job and Gender
                                HStack(spacing: 16) {
                                    // Job (Editable)
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Job")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        if isEditing {
                                            Menu {
                                                ForEach(jobs, id: \.self) { job in
                                                    Button(job) {
                                                        editedJob = job
                                                    }
                                                }
                                            } label: {
                                                HStack {
                                                    Text(editedJob)
                                                        .foregroundColor(.black)
                                                    Spacer()
                                                    Image(systemName: "chevron.down")
                                                        .foregroundColor(.gray)
                                                }
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(8)
                                            }
                                        } else {
                                            Text(user.job)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                    
                                    // Gender (Read-only)
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Gender")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        Text(user.gender)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white.opacity(0.5))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                        
                        Spacer()
                        
                        // Edit/Save Button
                        if isEditing {
                            Button(action: saveChanges) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                } else {
                                    Text("Save Changes")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                }
                            }
                            .background(Color(red: 0.7, green: 0.85, blue: 0.85))
                            .cornerRadius(25)
                            .padding(.horizontal, 40)
                            .disabled(isSaving)
                            
                            Button(action: cancelEdit) {
                                Text("Cancel")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            .padding(.horizontal, 40)
                        } else {
                            Button(action: startEditing) {
                                Text("Edit Profile")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(red: 0.7, green: 0.85, blue: 0.85))
                                    .cornerRadius(25)
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        // Log Out Button
                        Button(action: {
                            authService.logout()
                            dismiss()
                        }) {
                            Text("Log out")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func startEditing() {
        if let user = authService.currentUser {
            editedName = user.name
            editedCommunicationMethod = user.communicationMethod
            editedJob = user.job
            isEditing = true
        }
    }
    
    func cancelEdit() {
        isEditing = false
    }
    
    func saveChanges() {
        guard var user = authService.currentUser else { return }
        guard let userId = user.id else { return }
        
        // Validation
        guard !editedName.isEmpty, !editedCommunicationMethod.isEmpty else {
            errorMessage = "Name and Communication Method cannot be empty"
            showError = true
            return
        }
        
        isSaving = true
        
        // Update user object
        user.name = editedName
        user.communicationMethod = editedCommunicationMethod
        user.job = editedJob
        
        // Save to Firestore
        let db = Firestore.firestore()
        
        do {
            try db.collection("users").document(userId).setData(from: user) { error in
                isSaving = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else {
                    // Update local user
                    authService.currentUser = user
                    isEditing = false
                    print("✅ Profile updated successfully")
                }
            }
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
}
