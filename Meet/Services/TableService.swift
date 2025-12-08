import Foundation
import FirebaseFirestore
import Combine

class TableService: ObservableObject {
    @Published var tables: [MeetingTable] = []
    @Published var myBooking: MeetingTable?
    
    private let db = Firestore.firestore()
    
    // Fetch all tables for current month
    func fetchTables(userGender: String) {
        let currentMonth = getCurrentMonthString()
        
        db.collection("tables")
            .whereField("month", isEqualTo: currentMonth)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching tables: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.tables = documents.compactMap { doc in
                    try? doc.data(as: MeetingTable.self)
                }.filter { table in
                    // Filter women-only tables for male users
                    if userGender.lowercased() == "male" && table.isWomenOnly {
                        return false
                    }
                    return true
                }
            }
    }
    
    // Fetch user's current booking
    func fetchMyBooking(userId: String) {
        let currentMonth = getCurrentMonthString()
        
        db.collection("tables")
            .whereField("month", isEqualTo: currentMonth)
            .whereField("participantIDs", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching booking: \(error)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self?.myBooking = nil
                    return
                }
                
                self?.myBooking = try? document.data(as: MeetingTable.self)
            }
    }
    
    // Book a table
    func bookTable(tableId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let tableRef = db.collection("tables").document(tableId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(tableRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var table = try? document.data(as: MeetingTable.self) else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse table"])
                errorPointer?.pointee = error
                return nil
            }
            
            // Check if table is full
            if table.isFull {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Table is full"])
                errorPointer?.pointee = error
                return nil
            }
            
            // Check if user already booked
            if table.participantIDs.contains(userId) {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Already booked"])
                errorPointer?.pointee = error
                return nil
            }
            
            // Add user to participants
            table.participantIDs.append(userId)
            
            do {
                try transaction.setData(from: table, forDocument: tableRef)
            } catch let setError as NSError {
                errorPointer?.pointee = setError
                return nil
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Cancel booking
    func cancelBooking(tableId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let tableRef = db.collection("tables").document(tableId)
        
        tableRef.updateData([
            "participantIDs": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Generate tables for the month (admin function)
    func generateMonthlyTables() {
        let currentMonth = getCurrentMonthString()
        
        // First, check if tables already exist for this month
        db.collection("tables")
            .whereField("month", isEqualTo: currentMonth)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error checking tables: \(error)")
                    return
                }
                
                // If tables already exist, don't generate
                if let count = snapshot?.documents.count, count > 0 {
                    print("Tables already exist for \(currentMonth). Skipping generation.")
                    return
                }
                
                // Generate tables
                self?.createTables(for: currentMonth)
            }
    }

    private func createTables(for month: String) {
        let activities = ["Dinner", "Coffee", "Camping", "Walk", "Bike"]
        
        // Get random dates for this month
        let randomDates = getRandomDatesInCurrentMonth(count: 10) // 5 activities × 2 versions
        var dateIndex = 0
        
        // Create regular and women-only versions
        for activity in activities {
            // Regular table
            let regularTable = MeetingTable(
                id: nil,
                activityType: activity,
                isWomenOnly: false,
                month: month,
                meetingDate: randomDates[dateIndex],
                participantIDs: [],
                maxParticipants: 4,
                createdAt: Date()
            )
            dateIndex += 1
            
            // Women-only table
            let womenTable = MeetingTable(
                id: nil,
                activityType: activity,
                isWomenOnly: true,
                month: month,
                meetingDate: randomDates[dateIndex],
                participantIDs: [],
                maxParticipants: 4,
                createdAt: Date()
            )
            dateIndex += 1
            
            // Save to Firestore
            do {
                try db.collection("tables").addDocument(from: regularTable)
                try db.collection("tables").addDocument(from: womenTable)
                print("Created tables for \(activity)")
            } catch {
                print("Error creating tables: \(error)")
            }
        }
        
        print("Successfully generated all tables for \(month)")
    }

    // Generate random dates within the current month (only future dates)
    private func getRandomDatesInCurrentMonth(count: Int) -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        
        // Get current day number
        let currentDay = calendar.component(.day, from: now)
        
        // Get last day of current month
        guard let range = calendar.range(of: .day, in: .month, for: now) else {
            return Array(repeating: now, count: count)
        }
        let lastDay = range.count
        
        var dates: [Date] = []
        
        // Generate dates from today to end of month
        for _ in 0..<count {
            let randomDay = Int.random(in: currentDay...lastDay)
            
            var components = calendar.dateComponents([.year, .month], from: now)
            components.day = randomDay
            components.hour = Int.random(in: 14...20) // 2 PM to 8 PM
            components.minute = [0, 30].randomElement() ?? 0
            
            if let date = calendar.date(from: components), date > now {
                dates.append(date)
            } else {
                // If date is in past, use tomorrow
                if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                    dates.append(tomorrow)
                }
            }
        }
        
        return dates.sorted()
    }
    
    // Helper function to get current month string
    private func getCurrentMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
}

