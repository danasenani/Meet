import SwiftUI

struct BookingStatusView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var tableService: TableService
    @Environment(\.dismiss) var dismiss
    
    @State private var isCancelling = false
    @State private var showChatView = false
    @State private var showProfile = false
    @State private var showFeedback = false
    @State private var participants: [User] = []
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                if let booking = tableService.myBooking {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header
                            HStack {
                                VStack(alignment: localizationManager.isArabic ? .trailing : .leading, spacing: 4) {
                                    Text(strings.letsMeetIn)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 22) : .title2)
                                        .fontWeight(.semibold)
                                    Text(strings.riyadh)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Light", size: 22) : .title2)
                                        .fontWeight(.light)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: { showProfile = true }) {
                                    if let user = authService.currentUser {
                                        AvatarView(name: user.name, size: 40)
                                    }
                                }
                            }
                            .padding()
                            
                            Text(strings.youreIn)
                                .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 20) : .title3)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .padding(.top, 20)
                            
                            Spacer()
                                .frame(height: 20)
                            
                            // Table Info
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(getActivityColor(booking.activityType, isWomenOnly: booking.isWomenOnly))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: getActivityIcon(booking.activityType))
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                }
                                
                                Text(strings.displayName(activity: booking.activityType, isWomenOnly: booking.isWomenOnly))
                                    .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 20) : .title3)
                                    .fontWeight(.medium)
                                
                                Text(booking.formattedDate)
                                    .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                                    .foregroundColor(.gray)
                                
                                // Seats Status
                                VStack(spacing: 8) {
                                    Text(booking.isFull ? strings.tableFull : strings.seatsAvailable)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                        .fontWeight(.medium)
                                    
                                    Text("\(booking.seatsLeft)")
                                        .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 34) : .largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(booking.isFull ? .red : .green)
                                }
                                .padding(.top, 20)
                            }
                            
                            Spacer()
                                .frame(height: 40)
                            
                            // Buttons
                            VStack(spacing: 16) {
                                // Chat Button
                                Button(action: { showChatView = true }) {
                                    Text(strings.chatToMeet)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                                .background(booking.isFull ? Color(red: 0.7, green: 0.85, blue: 0.85) : Color.gray)
                                .cornerRadius(12)
                                .disabled(!booking.isFull)
                                
                                // Cancel Meeting Button
                                Button(action: cancelBooking) {
                                    if isCancelling {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                    } else {
                                        Text(strings.cancelMeeting)
                                            .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                    }
                                }
                                .background(Color(red: 0.95, green: 0.7, blue: 0.7))
                                .cornerRadius(12)
                                .disabled(isCancelling)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                        }
                    }
                } else {
                    Text("No booking found")
                        .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                        .foregroundColor(.gray)
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showChatView) {
                ChatView()
                    .environmentObject(authService)
                    .environmentObject(localizationManager)
                    .environmentObject(tableService)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authService)
                    .environmentObject(localizationManager)
            }
            .sheet(isPresented: $showFeedback) {
                if let booking = tableService.myBooking {
                    FeedbackView(
                        participants: participants,
                        tableId: booking.id ?? ""
                    )
                    .environmentObject(authService)
                    .environmentObject(localizationManager)
                }
            }
            .onAppear {
                checkAndShowFeedback()
            }
        }
    }
    
    func cancelBooking() {
        guard let userId = authService.currentUser?.id,
              let tableId = tableService.myBooking?.id else { return }
        
        isCancelling = true
        
        tableService.cancelBooking(tableId: tableId, userId: userId) { result in
            isCancelling = false
            
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                print("Error cancelling: \(error)")
            }
        }
    }
    
    func checkAndShowFeedback() {
        guard let booking = tableService.myBooking,
              let userId = authService.currentUser?.id,
              booking.hasMeetingPassed else {
            return
        }
        
        // Check if user already gave feedback
        let feedbackService = FeedbackService()
        feedbackService.hasFeedback(tableId: booking.id ?? "", raterId: userId) { hasFeedback in
            if !hasFeedback {
                // Fetch all participants
                fetchParticipants(participantIds: booking.participantIDs)
            }
        }
    }
    
    func fetchParticipants(participantIds: [String]) {
        var fetchedUsers: [User] = []
        let group = DispatchGroup()
        
        for participantId in participantIds {
            // Don't include current user
            if participantId == authService.currentUser?.id {
                continue
            }
            
            group.enter()
            let chatService = ChatService()
            chatService.fetchUser(userId: participantId) { user in
                if let user = user {
                    fetchedUsers.append(user)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            participants = fetchedUsers
            if !fetchedUsers.isEmpty {
                showFeedback = true
            }
        }
    }
    
    func getActivityIcon(_ activity: String) -> String {
        switch activity {
        case "Dinner": return "fork.knife"
        case "Coffee": return "cup.and.saucer.fill"
        case "Camping": return "tent.fill"
        case "Walk": return "figure.walk"
        case "Bike": return "bicycle"
        default: return "star.fill"
        }
    }
    
    func getActivityColor(_ activity: String, isWomenOnly: Bool) -> Color {
        if isWomenOnly {
            // All women-only events are pink
            return Color(red: 0.98, green: 0.8, blue: 0.8)
        } else {
            // Regular versions - unique vibrant colors
            switch activity {
            case "Dinner": return Color(red: 0.95, green: 0.75, blue: 0.6)   // Orange/Peach
            case "Coffee": return Color(red: 0.7, green: 0.8, blue: 0.9)     // Blue
            case "Camping": return Color(red: 0.9, green: 0.7, blue: 0.9)    // Purple
            case "Walk": return Color(red: 0.7, green: 0.85, blue: 0.85)     // Teal
            case "Bike": return Color(red: 0.8, green: 0.9, blue: 0.7)       // Green
            default: return Color.gray
            }
        }
    }
}

#Preview {
    BookingStatusView()
        .environmentObject(AuthService())
        .environmentObject(LocalizationManager())
        .environmentObject(TableService())
}
