import Foundation
import FirebaseFirestore
import Combine

class FeedbackService: ObservableObject {
    private let db = Firestore.firestore()
    
    // Submit feedback for a user
    func submitFeedback(tableId: String, raterId: String, ratedUserId: String, isPositive: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let feedback = Feedback(
            id: nil,
            tableId: tableId,
            raterId: raterId,
            ratedUserId: ratedUserId,
            isPositive: isPositive,
            createdAt: Date()
        )
        
        do {
            try db.collection("feedback").addDocument(from: feedback) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("✅ Feedback submitted")
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // Check if user already gave feedback for this table
    func hasFeedback(tableId: String, raterId: String, completion: @escaping (Bool) -> Void) {
        db.collection("feedback")
            .whereField("tableId", isEqualTo: tableId)
            .whereField("raterId", isEqualTo: raterId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking feedback: \(error)")
                    completion(false)
                    return
                }
                
                let hasFeedback = (snapshot?.documents.count ?? 0) > 0
                completion(hasFeedback)
            }
    }
    
    // Check how many negative ratings a user has (for flagging)
    func getNegativeRatingCount(userId: String, completion: @escaping (Int) -> Void) {
        db.collection("feedback")
            .whereField("ratedUserId", isEqualTo: userId)
            .whereField("isPositive", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting negative ratings: \(error)")
                    completion(0)
                    return
                }
                
                let count = snapshot?.documents.count ?? 0
                completion(count)
                
                // Auto-flag if 3+ negative ratings
                if count >= 3 {
                    self.flagUser(userId: userId)
                }
            }
    }
    
    // Flag a user (private function)
    private func flagUser(userId: String) {
        db.collection("flaggedUsers").document(userId).setData([
            "userId": userId,
            "flaggedAt": Date(),
            "reason": "Multiple negative ratings"
        ]) { error in
            if let error = error {
                print("Error flagging user: \(error)")
            } else {
                print("⚠️ User \(userId) has been flagged")
            }
        }
    }
}
