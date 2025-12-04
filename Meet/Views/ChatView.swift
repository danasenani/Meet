import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    
    // Mock messages for demo
    let mockMessages = [
        ChatMessage(text: "Hey everyone! Excited to meet you all!", isCurrentUser: false),
        ChatMessage(text: "Me too! Where should we meet?", isCurrentUser: true),
        ChatMessage(text: "How about the cafe near the park?", isCurrentUser: false),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.94, blue: 0.92)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                        
                        Text("Chat To Meet")
                            .font(.system(size: 20, weight: .medium))
                        
                        Spacer()
                        
                        // Participant avatars
                        HStack(spacing: -10) {
                            Circle()
                                .fill(Color(red: 0.7, green: 0.85, blue: 0.95))
                                .frame(width: 35, height: 35)
                            
                            Circle()
                                .fill(Color(red: 0.95, green: 0.7, blue: 0.85))
                                .frame(width: 35, height: 35)
                            
                            Circle()
                                .fill(Color(red: 0.85, green: 0.95, blue: 0.7))
                                .frame(width: 35, height: 35)
                        }
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                    
                    // Messages Area
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(mockMessages) { message in
                                MessageBubbleView(message: message)
                            }
                        }
                        .padding()
                    }
                    
                    // Message Input
                    HStack(spacing: 12) {
                        TextField("Type a message...", text: $messageText)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                        
                        Button(action: {
                            // Send message action (not implemented)
                            messageText = ""
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(red: 0.7, green: 0.85, blue: 0.85))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
            }
            
            if !message.isCurrentUser {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    )
            }
            
            Text(message.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(message.isCurrentUser ? Color(red: 0.7, green: 0.85, blue: 0.85) : Color.white)
                .foregroundColor(message.isCurrentUser ? .white : .black)
                .cornerRadius(20)
                .frame(maxWidth: 250, alignment: message.isCurrentUser ? .trailing : .leading)
            
            if message.isCurrentUser {
                Circle()
                    .fill(Color(red: 0.95, green: 0.7, blue: 0.7))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
            }
            
            if !message.isCurrentUser {
                Spacer()
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isCurrentUser: Bool
}

#Preview {
    ChatView()
}
