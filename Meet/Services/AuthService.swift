import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let db = Firestore.firestore()
    
    init() {
        checkAuth()
    }
    
    func checkAuth() {
        if let firebaseUser = Auth.auth().currentUser {
            isAuthenticated = true
            fetchUserData(uid: firebaseUser.uid)
        } else {
            isAuthenticated = false
        }
    }
    
    // Register new user
    func register(name: String, phoneNumber: String, password: String, communicationMethod: String, job: String, gender: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // Use phone number as email for Firebase Auth
        let email = "\(phoneNumber)@meet.app"
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            // Create user document in Firestore
            let user = User(
                id: uid,
                name: name,
                phoneNumber: phoneNumber,
                communicationMethod: communicationMethod,
                job: job,
                gender: gender,
                profileImageURL: nil,
                createdAt: Date()
            )
            
            self?.saveUserToFirestore(user: user) { result in
                switch result {
                case .success:
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Login
    func login(phoneNumber: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let email = "\(phoneNumber)@meet.app"
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            // Fetch user data BEFORE calling completion
            self?.fetchUserData(uid: uid) {
                completion(.success(()))
            }
        }
    }
    
    // Logout
    func logout() {
        try? Auth.auth().signOut()
        currentUser = nil
        isAuthenticated = false
    }
    
    // Save user to Firestore
    private func saveUserToFirestore(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = user.id else { return }
        
        do {
            try db.collection("users").document(uid).setData(from: user) { error in
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
    
    // Fetch user data
    private func fetchUserData(uid: String, completion: (() -> Void)? = nil) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user: \(error)")
                completion?()
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("User document doesn't exist")
                completion?()
                return
            }
            
            Task { @MainActor in
                do {
                    let user = try snapshot.data(as: User.self)
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    print("✅ User loaded: \(user.name)")
                    completion?()
                } catch {
                    print("Error decoding user: \(error)")
                    completion?()
                }
            }
        }
    }
}
