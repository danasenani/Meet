import Foundation
import FirebaseFirestore

struct Feedback: Identifiable, Codable, Sendable {
    @DocumentID var id: String?
    var tableId: String
    var raterId: String // Person giving the rating
    var ratedUserId: String // Person being rated
    var isPositive: Bool // true = "Ok to meet again", false = "Don't connect again"
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case tableId
        case raterId
        case ratedUserId
        case isPositive
        case createdAt
    }
}
