import SwiftUI

struct AfterFeedbackView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Checkmark
                ZStack {
                    Circle()
                        .fill(Color(red: 0.7, green: 0.85, blue: 0.85))
                        .frame(width: 200, height: 200)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(strings.thankYou)
                    .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 34) : .largeTitle)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Done Button
                Button(action: {
                    dismiss()
                }) {
                    Text(strings.done)
                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.95, green: 0.7, blue: 0.7))
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    AfterFeedbackView()
        .environmentObject(LocalizationManager())
}
