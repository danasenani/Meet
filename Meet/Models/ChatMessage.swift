import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable, Sendable {
    @DocumentID var id: String?
    var tableId: String
    var senderId: String
    var senderName: String
    var text: String
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case tableId
        case senderId
        case senderName
        case text
        case timestamp
    }
}

