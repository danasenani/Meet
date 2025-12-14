import Foundation
import FirebaseFirestore
import Combine

class TableService: ObservableObject {
    @Published var tables: [MeetingTable] = []
    @Published var myBooking: MeetingTable?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Fetch tables based on user gender
    func fetchTables(userGender: String) {
        print("📋 Fetching tables for gender: \(userGender)")
        
        // Stop any existing listener
        listener?.remove()
        
        // Determine which tables to show
        let query: Query
        if userGender == "Female" {
            // Female users see: all tables + women-only tables
            query = db.collection("tables")
                .whereField("meetingDate", isGreaterThan: Date())
                .order(by: "meetingDate")
        } else {
            // Male users see: only non-women-only tables
            query = db.collection("tables")
                .whereField("isWomenOnly", isEqualTo: false)
                .whereField("meetingDate", isGreaterThan: Date())
                .order(by: "meetingDate")
        }
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error fetching tables: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("📋 No tables found")
                self?.tables = []
                return
            }
            
            self?.tables = documents.compactMap { doc -> MeetingTable? in
                try? doc.data(as: MeetingTable.self)
            }
            
            print("✅ Fetched \(self?.tables.count ?? 0) tables")
        }
    }
    
    // Fetch user's current booking
    func fetchMyBooking(userId: String) {
        print("📋 Fetching booking for user: \(userId)")
        
        db.collection("tables")
            .whereField("participantIDs", arrayContains: userId)
            .whereField("meetingDate", isGreaterThan: Date())
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching booking: \(error)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("📋 No active booking found")
                    self?.myBooking = nil
                    return
                }
                
                self?.myBooking = try? document.data(as: MeetingTable.self)
                print("✅ Found active booking: \(self?.myBooking?.activityType ?? "unknown")")
            }
    }
    
    // Book a table
    func bookTable(tableId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("📝 Booking table \(tableId) for user \(userId)")
        
        let tableRef = db.collection("tables").document(tableId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let tableDocument: DocumentSnapshot
            do {
                try tableDocument = transaction.getDocument(tableRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let participantIDs = tableDocument.data()?["participantIDs"] as? [String],
                  let maxParticipants = tableDocument.data()?["maxParticipants"] as? Int else {
                let error = NSError(domain: "TableService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid table data"])
                errorPointer?.pointee = error
                return nil
            }
            
            // Check if table is full
            if participantIDs.count >= maxParticipants {
                let error = NSError(domain: "TableService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Table is full"])
                errorPointer?.pointee = error
                return nil
            }
            
            // Check if user already booked
            if participantIDs.contains(userId) {
                let error = NSError(domain: "TableService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Already booked"])
                errorPointer?.pointee = error
                return nil
            }
            
            // Add user to participants
            transaction.updateData([
                "participantIDs": FieldValue.arrayUnion([userId])
            ], forDocument: tableRef)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("❌ Booking failed: \(error)")
                completion(.failure(error))
            } else {
                print("✅ Booking successful")
                completion(.success(()))
            }
        }
    }
    
    // Cancel booking
    func cancelBooking(tableId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🗑️ Cancelling booking for table \(tableId)")
        
        db.collection("tables").document(tableId).updateData([
            "participantIDs": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("❌ Cancel failed: \(error)")
                completion(.failure(error))
            } else {
                print("✅ Booking cancelled")
                completion(.success(()))
            }
        }
    }
    
    // Clean up tables with past dates
    func cleanupPastTables() {
        print("🧹 Cleaning up past tables...")
        
        let now = Date()
        
        db.collection("tables")
            .whereField("meetingDate", isLessThan: now)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching past tables: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                print("🧹 Found \(documents.count) past tables to delete")
                
                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("❌ Error deleting table: \(error)")
                        } else {
                            print("✅ Deleted past table: \(document.documentID)")
                        }
                    }
                }
            }
    }
    
    // Generate monthly tables (call this once to create tables for the month)
    func generateMonthlyTables() {
        print("🔨 Generating monthly tables...")
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if tables already exist for this month
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        db.collection("tables")
            .whereField("meetingDate", isGreaterThanOrEqualTo: startOfMonth)
            .whereField("meetingDate", isLessThanOrEqualTo: endOfMonth)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error checking existing tables: \(error)")
                    return
                }
                
                if let count = snapshot?.documents.count, count > 0 {
                    print("✅ Tables already exist for this month (\(count) tables)")
                    return
                }
                
                print("📅 No tables found, creating new ones...")
                self?.createTablesForMonth()
            }
    }
    
    private func createTablesForMonth() {
        let calendar = Calendar.current
        let now = Date()
        
        // Get dates for the rest of the month
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                            to: calendar.startOfDay(for: now)) else { return }
        
        var currentDate = calendar.startOfDay(for: now)
        
        let activities = ["Dinner", "Coffee", "Camping", "Walk", "Bike"]
        
        while currentDate <= endOfMonth {
            // Skip if date is in the past
            if currentDate >= now {
                // Create one table per activity type
                for activity in activities {
                    // Regular table
                    // Regular table
                    let regularTable = MeetingTable(
                        id: nil,
                        activityType: activity,
                        isWomenOnly: false,
                        month: currentDate.formatted(.dateTime.month(.wide).year()),
                        meetingDate: currentDate,
                        participantIDs: [],
                        maxParticipants: 4,
                        createdAt: Date()
                    )

                    // Women-only table
                    let womenOnlyTable = MeetingTable(
                        id: nil,
                        activityType: activity,
                        isWomenOnly: true,
                        month: currentDate.formatted(.dateTime.month(.wide).year()),
                        meetingDate: currentDate,
                        participantIDs: [],
                        maxParticipants: 4,
                        createdAt: Date()
                    )
                    // Save to Firebase
                    do {
                        try db.collection("tables").addDocument(from: regularTable)
                        try db.collection("tables").addDocument(from: womenOnlyTable)
                    } catch {
                        print("❌ Error creating table: \(error)")
                    }
                }
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        print("✅ Monthly tables created")
    }
    
    deinit {
        listener?.remove()
    }
}
