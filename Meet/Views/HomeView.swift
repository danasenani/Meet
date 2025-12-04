import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var tableService = TableService()
    @State private var showProfile = false
    
    private func loadData() {
        print("🔍 Loading data...")
        print("🔍 Current user: \(authService.currentUser?.name ?? "nil")")
        
        if let user = authService.currentUser {
            print("🔍 Fetching tables for gender: \(user.gender)")
            
            // First, try to generate tables if none exist for this month
            tableService.generateMonthlyTables()
            
            // Then fetch tables
            tableService.fetchTables(userGender: user.gender)
            tableService.fetchMyBooking(userId: user.id ?? "")
        } else {
            print("❌ No current user found!")
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                    
                    // Subtitle
                    Text("Choose your event")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    
                    // Tables List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(tableService.tables) { table in
                                NavigationLink(destination: ConfirmBookingView(table: table)
                                    .environmentObject(authService)
                                    .environmentObject(tableService)) {
                                    TableRowView(table: table)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authService)
            }
            .onAppear {
                loadData()
            }
            .onReceive(authService.$currentUser) { user in
                if user != nil {
                    loadData()
                }
            }
            .overlay(
                // Generate Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            tableService.generateMonthlyTables()
                        }) {
                            Text("Generate")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            )
        }
    }
}

struct TableRowView: View {
    let table: MeetingTable
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(getActivityColor())
                    .frame(width: 60, height: 60)
                
                Image(systemName: getActivityIcon())
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(table.displayName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                Text(table.formattedDate)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
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
    HomeView()
        .environmentObject(AuthService())
}
