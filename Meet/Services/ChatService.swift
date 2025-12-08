import Foundation
import FirebaseFirestore
import Combine

class ChatService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Fetch messages for a specific table
    func fetchMessages(for tableId: String) {
        // Remove old listener if exists
        listener?.remove()
        
        // Listen for real-time updates
        listener = db.collection("chats")
            .whereField("tableId", isEqualTo: tableId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.messages = documents.compactMap { doc in
                    try? doc.data(as: ChatMessage.self)
                }
            }
    }
    
    // Send a message
    func sendMessage(tableId: String, senderId: String, senderName: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let message = ChatMessage(
            id: nil,
            tableId: tableId,
            senderId: senderId,
            senderName: senderName,
            text: text,
            timestamp: Date()
        )
        
        do {
            try db.collection("chats").addDocument(from: message) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // Fetch user by ID
    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil)
                return
            }
            
            do {
                let user = try snapshot.data(as: User.self)
                completion(user)
            } catch {
                print("Error decoding user: \(error)")
                completion(nil)
            }
        }
    }
    
    // Clean up listener when done
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}
