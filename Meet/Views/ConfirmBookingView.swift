import SwiftUI

struct ConfirmBookingView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var tableService: TableService
    @Environment(\.dismiss) var dismiss
    
    let table: MeetingTable
    
    @State private var isBooking = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToBookingStatus = false
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Confirm Meeting")
                    .font(.system(size: 28, weight: .semibold))
                    .padding(.top, 40)
                
                Spacer()
                
                // Table Icon
                ZStack {
                    Circle()
                        .fill(getActivityColor())
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: getActivityIcon())
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                // Table Name
                Text(table.displayName)
                    .font(.system(size: 24, weight: .medium))
                    .padding(.top, 20)
                
                Text(table.formattedDate)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                // Seats Available
                Text("Seats Available")
                    .font(.system(size: 18, weight: .medium))
                    .padding(.top, 30)

                Text("\(table.seatsLeft)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(table.isFull ? .red : .green)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    // Meet Button
                    Button(action: bookTable) {
                        if isBooking {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                        } else {
                            Text("Meet")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                        }
                    }
                    .background(table.isFull ? Color.gray : Color(red: 0.7, green: 0.85, blue: 0.85))
                    .cornerRadius(12)
                    .disabled(table.isFull || isBooking)
                    
                    // Cancel Button
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
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
        switch table.activityType {
        case "Dinner": return Color(red: 0.95, green: 0.7, blue: 0.7)
        case "Coffee": return Color(red: 0.7, green: 0.8, blue: 0.9)
        case "Camping": return Color(red: 0.9, green: 0.7, blue: 0.9)
        case "Walk": return Color(red: 0.95, green: 0.7, blue: 0.7)
        case "Bike": return Color(red: 0.8, green: 0.9, blue: 0.7)
        default: return Color.gray
        }
    }
}

#Preview {
    ConfirmBookingView(table: MeetingTable(
        id: "1",
        activityType: "Coffee",
        isWomenOnly: false,
        month: "December 2024",
        meetingDate: Date(), // ADD THIS LINE
        participantIDs: [],
        maxParticipants: 6,
        createdAt: Date()
    ))
    .environmentObject(AuthService())
    .environmentObject(TableService())
}

