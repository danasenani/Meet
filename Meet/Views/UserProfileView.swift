import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    let user: User
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Close Button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                // Profile Picture
                AvatarView(name: user.name, size: 100)
                    .padding(.top, 40)
                
                // Name
                Text(user.name)
                    .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 24) : .title2)
                    .fontWeight(.semibold)
                
                // Communication Method (Most Important!)
                VStack(spacing: 8) {
                    Text(strings.communicationMethod)
                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 15) : .caption)
                        .foregroundColor(.gray)
                    
                    Text(user.communicationMethod)
                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 20) : .title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.7, green: 0.85, blue: 0.85))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 40)
                
                // Job
                VStack(alignment: localizationManager.isArabic ? .trailing : .leading, spacing: 8) {
                    Text(strings.job)
                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 15) : .caption)
                        .foregroundColor(.gray)
                    
                    Text(user.job)
                        .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: localizationManager.isArabic ? .trailing : .leading)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

#Preview {
    UserProfileView(user: User(
        id: "1",
        name: "Dana Ali",
        phoneNumber: "0501234567",
        communicationMethod: "Sign language",
        job: "Designer",
        gender: "Female",
        profileImageURL: nil,
        createdAt: Date()
    ))
    .environmentObject(LocalizationManager())
}
