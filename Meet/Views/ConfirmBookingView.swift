import SwiftUI

struct ConfirmBookingView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var tableService: TableService
    @Environment(\.dismiss) var dismiss
    
    let table: MeetingTable
    
    @State private var isBooking = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToBookingStatus = false
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text(strings.confirmMeeting)
                        .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 28) : .title)
                        .fontWeight(.semibold)
                        .padding(.top, 40)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Table Icon
                    ZStack {
                        Circle()
                            .fill(getActivityColor())
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: getActivityIcon())
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    
                    // Table Name
                    Text(strings.displayName(activity: table.activityType, isWomenOnly: table.isWomenOnly))
                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 22) : .title2)
                        .fontWeight(.medium)
                        .padding(.top, 20)
                    
                    Text(table.formattedDate)
                        .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                        .foregroundColor(.gray)
                    
                    // Seats Available
                    Text(strings.seatsAvailable)
                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                        .fontWeight(.medium)
                        .padding(.top, 30)
                    
                    Text("\(table.seatsLeft)")
                        .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 34) : .largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(table.isFull ? .red : .green)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Meet Button
                        Button(action: bookTable) {
                            if isBooking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text(strings.meet)
                                    .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(table.isFull ? Color.gray : Color(red: 0.7, green: 0.85, blue: 0.85))
                        .cornerRadius(12)
                        .disabled(table.isFull || isBooking)
                        
                        // Cancel Button
                        Button(action: { dismiss() }) {
                            Text(strings.cancel)
                                .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: $navigateToBookingStatus) {
            BookingStatusView()
                .environmentObject(authService)
                .environmentObject(localizationManager)
                .environmentObject(tableService)
        }
    }
    
    func bookTable() {
        guard let userId = authService.currentUser?.id,
              let tableId = table.id else { return }
        
        isBooking = true
        
        tableService.bookTable(tableId: tableId, userId: userId) { result in
            isBooking = false
            
            switch result {
            case .success:
                navigateToBookingStatus = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func getActivityIcon() -> String {
        switch table.activityType {
        case "Dinner": return "fork.knife"
        case "Coffee": return "cup.and.saucer.fill"
        case "Camping": return "tent.fill"
        case "Walk": return "figure.walk"
        case "Bike": return "bicycle"
        default: return "star.fill"
        }
    }
    
    func getActivityColor() -> Color {
        if table.isWomenOnly {
            // All women-only events are pink
            return Color(red: 0.98, green: 0.8, blue: 0.8)
        } else {
            // Regular versions - unique vibrant colors
            switch table.activityType {
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
    ConfirmBookingView(table: MeetingTable(
        id: "1",
        activityType: "Coffee",
        isWomenOnly: false,
        month: "December 2024",
        meetingDate: Date(),
        participantIDs: [],
        maxParticipants: 4,
        createdAt: Date()
    ))
    .environmentObject(AuthService())
    .environmentObject(LocalizationManager())
    .environmentObject(TableService())
}

