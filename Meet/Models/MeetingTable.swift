import Foundation
import FirebaseFirestore

struct MeetingTable: Identifiable, Codable, Sendable {
    @DocumentID var id: String?
    var activityType: String // "Dinner", "Coffee", "Camping", "Walk", "Bike"
    var isWomenOnly: Bool
    var month: String // e.g., "December 2024"
    var meetingDate: Date // The actual date of the meeting
    var participantIDs: [String] // Array of user IDs
    var maxParticipants: Int // Always 6
    var createdAt: Date
    
    var seatsLeft: Int {
        return maxParticipants - participantIDs.count
    }
    
    var isFull: Bool {
        return participantIDs.count >= maxParticipants
    }
    
    var displayName: String {
        return isWomenOnly ? "Women-only \(activityType)" : activityType
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: meetingDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case activityType
        case isWomenOnly
        case month
        case meetingDate
        case participantIDs
        case maxParticipants
        case createdAt
    }
}

