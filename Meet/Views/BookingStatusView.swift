import SwiftUI

struct BookingStatusView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var tableService: TableService
    @Environment(\.dismiss) var dismiss
    
    @State private var isCancelling = false
    @State private var showChatView = false
    @State private var showProfile = false
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            if let booking = tableService.myBooking {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Let's Meet In")
                                .font(.system(size: 24, weight: .semibold))
                            Text("Riyadh")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: { showProfile = true }) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    .padding()
                    
                    Text("You're in!")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Table Info
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(getActivityColor(booking.activityType))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: getActivityIcon(booking.activityType))
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text(booking.displayName)
                            .font(.system(size: 22, weight: .medium))
                        
                        Text(booking.formattedDate)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        // Seats Status
                        VStack(spacing: 8) {
                            Text(booking.isFull ? "Table Full" : "Seats Available")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("\(booking.seatsLeft)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(booking.isFull ? .red : .green)
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Chat Button
                        Button(action: { showChatView = true }) {
                            Text("Chat To Meet")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
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
                                    .frame(height: 55)
                            } else {
                                Text("Cancel Meeting")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                            }
                        }
                        .background(Color(red: 0.95, green: 0.7, blue: 0.7))
                        .cornerRadius(12)
                        .disabled(isCancelling)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            } else {
                Text("No booking found")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showChatView) {
            ChatView()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(authService)
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
    
    func getActivityColor(_ activity: String) -> Color {
        switch activity {
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
    BookingStatusView()
        .environmentObject(AuthService())
        .environmentObject(TableService())
}
