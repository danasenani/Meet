import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var tableService = TableService()
    @State private var showProfile = false
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
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
            Group {
                if tableService.myBooking != nil {
                    // User has active booking - show booking status
                    BookingStatusView()
                        .environmentObject(authService)
                        .environmentObject(localizationManager)
                        .environmentObject(tableService)
                } else {
                    // No booking - show event list
                    ZStack {
                        Color(red: 0.95, green: 0.94, blue: 0.92)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
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
                            
                            // Subtitle
                            Text(strings.chooseYourEvent)
                                .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: localizationManager.isArabic ? .trailing : .leading)
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            
                            // Tables List
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(tableService.tables) { table in
                                        NavigationLink(destination: ConfirmBookingView(table: table)
                                            .environmentObject(authService)
                                            .environmentObject(localizationManager)
                                            .environmentObject(tableService)) {
                                            TableRowView(table: table, localizationManager: localizationManager)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authService)
                    .environmentObject(localizationManager)
            }
            .onAppear {
                loadData()
            }
            .onReceive(authService.$currentUser) { user in
                if user != nil {
                    loadData()
                }
            }
        }
    }
}

struct TableRowView: View {
    let table: MeetingTable
    @ObservedObject var localizationManager: LocalizationManager
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(getActivityColor())
                    .frame(width: 60, height: 60)
                
                Image(systemName: getActivityIcon())
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: localizationManager.isArabic ? .trailing : .leading, spacing: 4) {
                Text(strings.displayName(activity: table.activityType, isWomenOnly: table.isWomenOnly))
                    .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                Text(table.formattedDate)
                    .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 15) : .subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: localizationManager.isArabic ? "chevron.left" : "chevron.right")
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
    HomeView()
        .environmentObject(AuthService())
        .environmentObject(LocalizationManager())
}
