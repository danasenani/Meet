import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Sendable {
    @DocumentID var id: String?
    var name: String
    var phoneNumber: String
    var communicationMethod: String
    var job: String
    var gender: String
    var profileImageURL: String?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phoneNumber
        case communicationMethod
        case job
        case gender
        case profileImageURL
        case createdAt
    }
}
