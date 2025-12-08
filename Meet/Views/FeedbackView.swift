import SwiftUI

struct FeedbackView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    let participants: [User]
    let tableId: String
    
    @StateObject private var feedbackService = FeedbackService()
    @State private var ratings: [String: Bool?] = [:] // userId: true/false/nil
    @State private var isSubmitting = false
    @State private var showThankYou = false
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Text(strings.feedback)
                            .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 28) : .title)
                            .fontWeight(.semibold)
                            .padding(.top, 40)
                        
                        // Feedback for each participant
                        ForEach(participants) { participant in
                            VStack(spacing: 16) {
                                Text("\(strings.howWas) \(participant.name)\(localizationManager.isArabic ? "" : "?")")
                                    .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                                
                                // Profile Picture
                                AvatarView(name: participant.name, size: 80)
                                
                                // Positive Button
                                Button(action: {
                                    ratings[participant.id ?? ""] = true
                                }) {
                                    Text(strings.okToMeetAgain)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(ratings[participant.id ?? ""] == true ? Color(red: 0.7, green: 0.85, blue: 0.85) : Color(red: 0.7, green: 0.85, blue: 0.85).opacity(0.5))
                                        .cornerRadius(25)
                                }
                                .padding(.horizontal, 60)
                                
                                // Negative Button
                                Button(action: {
                                    ratings[participant.id ?? ""] = false
                                }) {
                                    Text(strings.dontConnectAgain)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(ratings[participant.id ?? ""] == false ? Color(red: 0.95, green: 0.7, blue: 0.7) : Color(red: 0.95, green: 0.7, blue: 0.7).opacity(0.5))
                                        .cornerRadius(25)
                                }
                                .padding(.horizontal, 60)
                            }
                            .padding(.vertical, 10)
                        }
                        
                        // Skip Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text(strings.skip)
                                .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
                
                // Floating Done Button (only if at least one rating given)
                if ratings.values.contains(where: { $0 != nil }) {
                    VStack {
                        Spacer()
                        
                        Button(action: submitFeedback) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text(strings.done)
                                    .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(Color(red: 0.95, green: 0.7, blue: 0.7))
                        .cornerRadius(25)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                        .disabled(isSubmitting)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $showThankYou) {
                AfterFeedbackView()
                    .environmentObject(localizationManager)
            }
        }
    }
    
    func submitFeedback() {
        guard let raterId = authService.currentUser?.id else { return }
        
        isSubmitting = true
        
        let group = DispatchGroup()
        var hasError = false
        
        // Submit each rating
        for (userId, rating) in ratings {
            guard let rating = rating else { continue } // Skip nil ratings
            
            group.enter()
            feedbackService.submitFeedback(
                tableId: tableId,
                raterId: raterId,
                ratedUserId: userId,
                isPositive: rating
            ) { result in
                if case .failure = result {
                    hasError = true
                }
                group.leave()
            }
        }
        
        // When all submissions complete
        group.notify(queue: .main) {
            isSubmitting = false
            
            if !hasError {
                showThankYou = true
            }
        }
    }
}

#Preview {
    FeedbackView(
        participants: [
            User(id: "1", name: "Abdullah", phoneNumber: "123", communicationMethod: "Sign language", job: "Engineer", gender: "Male", profileImageURL: nil, createdAt: Date()),
            User(id: "2", name: "Dana", phoneNumber: "456", communicationMethod: "Text preferred", job: "Designer", gender: "Female", profileImageURL: nil, createdAt: Date())
        ],
        tableId: "table123"
    )
    .environmentObject(AuthService())
    .environmentObject(LocalizationManager())
}
