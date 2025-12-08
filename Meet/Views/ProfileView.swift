import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedCommunicationMethod = ""
    @State private var editedJob = ""
    @State private var isSaving = false
    @State private var showLanguagePicker = false
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: localizationManager.isArabic ? "chevron.right" : "chevron.left")
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Text(strings.profile)
                                .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 20) : .headline)
                            
                            Spacer()
                            
                            Button(action: {
                                if isEditing {
                                    saveProfile()
                                } else {
                                    startEditing()
                                }
                            }) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text(isEditing ? strings.save : strings.edit)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                        .foregroundColor(.black)
                                }
                            }
                            .disabled(isSaving)
                        }
                        .padding()
                        
                        // Profile Picture
                        if let user = authService.currentUser {
                            AvatarView(name: user.name, size: 100)
                                .padding(.top, 20)
                        }
                        
                        // Profile Info
                        VStack(spacing: 16) {
                            if let user = authService.currentUser {
                                // Name
                                ProfileField(
                                    label: strings.name,
                                    value: isEditing ? $editedName : .constant(user.name),
                                    isEditing: isEditing,
                                    isArabic: localizationManager.isArabic
                                )
                                
                                // Phone Number (not editable)
                                ProfileField(
                                    label: strings.phoneNumber,
                                    value: .constant(user.phoneNumber),
                                    isEditing: false,
                                    isArabic: localizationManager.isArabic
                                )
                                
                                // Communication Method
                                ProfileField(
                                    label: strings.communicationMethod,
                                    value: isEditing ? $editedCommunicationMethod : .constant(user.communicationMethod),
                                    isEditing: isEditing,
                                    isArabic: localizationManager.isArabic
                                )
                                
                                // Job
                                ProfileField(
                                    label: strings.job,
                                    value: isEditing ? $editedJob : .constant(user.job),
                                    isEditing: isEditing,
                                    isArabic: localizationManager.isArabic
                                )
                                
                                // Gender (not editable)
                                ProfileField(
                                    label: strings.gender,
                                    value: .constant(user.gender == "Male" ? strings.male : strings.female),
                                    isEditing: false,
                                    isArabic: localizationManager.isArabic
                                )
                            }
                            
                            // Language Selector
                            Button(action: { showLanguagePicker = true }) {
                                HStack {
                                    Text(strings.languageText)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 15) : .caption)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: localizationManager.isArabic ? .trailing : .leading)
                                    
                                    Text(localizationManager.currentLanguage.displayName)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                                        .foregroundColor(.black)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        
                        // Logout Button
                        Button(action: {
                            authService.logout()
                            dismiss()
                        }) {
                            Text(strings.logout)
                                .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.95, green: 0.7, blue: 0.7))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 30)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .confirmationDialog(strings.languageText, isPresented: $showLanguagePicker, titleVisibility: .visible) {
                ForEach(Language.allCases, id: \.self) { language in
                    Button(language.displayName) {
                        localizationManager.currentLanguage = language
                    }
                }
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
    
    func saveProfile() {
        guard let userId = authService.currentUser?.id else { return }
        
        isSaving = true
        
        authService.updateProfile(
            userId: userId,
            name: editedName,
            communicationMethod: editedCommunicationMethod,
            job: editedJob
        ) { result in
            isSaving = false
            isEditing = false
            
            switch result {
            case .success:
                print("✅ Profile updated")
            case .failure(let error):
                print("❌ Error updating profile: \(error)")
            }
        }
    }
}

struct ProfileField: View {
    let label: String
    @Binding var value: String
    let isEditing: Bool
    let isArabic: Bool
    
    var body: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 8) {
            Text(label)
                .font(isArabic ? .custom("Dubai-Medium", size: 15) : .caption)
                .foregroundColor(.gray)
            
            if isEditing {
                TextField(label, text: $value)
                    .font(isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
            } else {
                Text(value)
                    .font(isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
        .environmentObject(LocalizationManager())
}
