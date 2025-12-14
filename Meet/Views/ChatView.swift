import SwiftUI

struct ChatView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var tableService: TableService
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var isSending = false
    @State private var selectedUser: User?
    @State private var showUserProfile = false
    @State private var showParticipantsList = false
    @State private var participants: [User] = []
    
    var strings: LocalizedStrings {
        LocalizedStrings(lang: localizationManager.currentLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            chatService.stopListening()
                            dismiss()
                        }) {
                            Image(systemName: localizationManager.isArabic ? "chevron.right" : "chevron.left")
                                .foregroundColor(.black)
                        }
                        
                        Text(strings.chatToMeet)
                            .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 17) : .headline)
                        
                        Spacer()
                        
                        // Participant count - TAPPABLE
                        if let booking = tableService.myBooking {
                            Button(action: {
                                fetchParticipants()
                                showParticipantsList = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .font(.caption)
                                    Text("\(booking.participantIDs.count)")
                                        .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 13) : .caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                    
                    // Messages Area
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 16) {
                                if chatService.messages.isEmpty {
                                    Text(strings.noMessages)
                                        .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                                        .foregroundColor(.gray)
                                        .padding(.top, 40)
                                        .multilineTextAlignment(.center)
                                } else {
                                    ForEach(chatService.messages) { message in
                                        MessageBubbleView(
                                            message: message,
                                            isCurrentUser: message.senderId == authService.currentUser?.id,
                                            isArabic: localizationManager.isArabic,
                                            onAvatarTap: {
                                                // Fetch and show user profile
                                                chatService.fetchUser(userId: message.senderId) { user in
                                                    if let user = user {
                                                        selectedUser = user
                                                        showUserProfile = true
                                                    }
                                                }
                                            }
                                        )
                                        .id(message.id)
                                    }
                                }
                            }
                            .padding()
                        }
                        .onChange(of: chatService.messages.count) { oldValue, newValue in
                            // Auto-scroll to bottom when new message arrives
                            if let lastMessage = chatService.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Message Input
                    HStack(spacing: 12) {
                        TextField(strings.typeMessage, text: $messageText, axis: .vertical)
                            .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                            .disabled(isSending)
                            .multilineTextAlignment(localizationManager.isArabic ? .trailing : .leading)
                        
                        Button(action: sendMessage) {
                            if isSending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 50, height: 50)
                            } else {
                                Image(systemName: localizationManager.isArabic ? "paperplane.fill" : "paperplane.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(messageText.isEmpty ? Color.gray : Color(red: 0.7, green: 0.85, blue: 0.85))
                                    .clipShape(Circle())
                                    .rotationEffect(.degrees(localizationManager.isArabic ? 180 : 0))
                            }
                        }
                        .disabled(messageText.isEmpty || isSending)
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if let tableId = tableService.myBooking?.id {
                    chatService.fetchMessages(for: tableId)
                }
            }
            .onDisappear {
                chatService.stopListening()
            }
            .sheet(isPresented: $showUserProfile) {
                if let user = selectedUser {
                    UserProfileView(user: user)
                        .environmentObject(localizationManager)
                }
            }
            .sheet(isPresented: $showParticipantsList) {
                ParticipantsListView(participants: participants)
                    .environmentObject(localizationManager)
                    .presentationDetents([.medium])
            }
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty,
              let tableId = tableService.myBooking?.id,
              let userId = authService.currentUser?.id,
              let userName = authService.currentUser?.name else {
            return
        }
        
        let textToSend = messageText
        messageText = "" // Clear immediately for better UX
        isSending = true
        
        chatService.sendMessage(
            tableId: tableId,
            senderId: userId,
            senderName: userName,
            text: textToSend
        ) { result in
            isSending = false
            
            switch result {
            case .success:
                print("✅ Message sent")
            case .failure(let error):
                print("❌ Error sending message: \(error)")
                // Restore message text if failed
                messageText = textToSend
            }
        }
    }
    
    func fetchParticipants() {
        guard let participantIds = tableService.myBooking?.participantIDs else { return }
        
        var fetchedUsers: [User] = []
        let group = DispatchGroup()
        
        for participantId in participantIds {
            group.enter()
            chatService.fetchUser(userId: participantId) { user in
                if let user = user {
                    fetchedUsers.append(user)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            participants = fetchedUsers
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    let isArabic: Bool
    let onAvatarTap: () -> Void
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            if !isCurrentUser {
                Button(action: onAvatarTap) {
                    AvatarView(name: message.senderName, size: 30)
                }
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Button(action: onAvatarTap) {
                        Text(message.senderName)
                            .font(isArabic ? .custom("Dubai-Medium", size: 13) : .caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(message.text)
                    .font(isArabic ? .custom("Dubai-Regular", size: 17) : .body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isCurrentUser ? Color(red: 0.7, green: 0.85, blue: 0.85) : Color.white)
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(20)
            }
            .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
            
            if isCurrentUser {
                AvatarView(name: message.senderName, size: 30)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
}

// NEW: Participants List View
struct ParticipantsListView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedUser: User?
    @State private var showUserProfile = false
    
    let participants: [User]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text(localizationManager.isArabic ? "المشاركون" : "Participants")
                            .font(localizationManager.isArabic ? .custom("Dubai-Bold", size: 20) : .headline)
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    
                    // Participants List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(participants) { participant in
                                Button(action: {
                                    selectedUser = participant
                                    showUserProfile = true
                                }) {
                                    HStack(spacing: 16) {
                                        AvatarView(name: participant.name, size: 50)
                                        
                                        VStack(alignment: localizationManager.isArabic ? .trailing : .leading, spacing: 4) {
                                            Text(participant.name)
                                                .font(localizationManager.isArabic ? .custom("Dubai-Medium", size: 17) : .body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.black)
                                            
                                            Text(participant.communicationMethod)
                                                .font(localizationManager.isArabic ? .custom("Dubai-Regular", size: 15) : .subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment: localizationManager.isArabic ? .trailing : .leading)
                                        
                                        Image(systemName: localizationManager.isArabic ? "chevron.left" : "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showUserProfile) {
                if let user = selectedUser {
                    UserProfileView(user: user)
                        .environmentObject(localizationManager)
                }
            }
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AuthService())
        .environmentObject(LocalizationManager())
        .environmentObject(TableService())
}
