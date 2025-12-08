import SwiftUI

struct AvatarView: View {
    let name: String
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(colorForName(name))
            .frame(width: size, height: size)
            .overlay(
                Text(initials(from: name))
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(.white)
            )
    }
    
    // Generate initials from name
    private func initials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            let first = words[0].prefix(1)
            let second = words[1].prefix(1)
            return "\(first)\(second)".uppercased()
        } else if let first = words.first {
            return String(first.prefix(1)).uppercased()
        }
        return "?"
    }
    
    // Generate consistent color based on name
    private func colorForName(_ name: String) -> Color {
        let colors: [Color] = [
            Color(red: 0.95, green: 0.7, blue: 0.7),   // Pink/Coral
            Color(red: 0.7, green: 0.8, blue: 0.9),    // Blue
            Color(red: 0.9, green: 0.7, blue: 0.9),    // Purple/Lavender
            Color(red: 0.7, green: 0.85, blue: 0.85),  // Teal/Cyan
            Color(red: 0.8, green: 0.9, blue: 0.7),    // Green
            Color(red: 0.95, green: 0.85, blue: 0.7),  // Peach/Orange
            Color(red: 0.85, green: 0.75, blue: 0.9),  // Light Purple
            Color(red: 0.7, green: 0.9, blue: 0.8),    // Mint Green
            Color(red: 0.9, green: 0.8, blue: 0.7),    // Tan
            Color(red: 0.8, green: 0.7, blue: 0.9),    // Violet
        ]
        
        // Better hash function - sum ASCII values of name
        var hash = 0
        for char in name.unicodeScalars {
            hash += Int(char.value)
        }
        
        // Use absolute value and modulo to pick color
        let index = abs(hash) % colors.count
        return colors[index]
    }
}

#Preview {
    HStack(spacing: 20) {
        AvatarView(name: "Dana Ali", size: 50)
        AvatarView(name: "Abdullah Ahmed", size: 50)
        AvatarView(name: "Sarah", size: 50)
        AvatarView(name: "Mohammed", size: 50)
    }
    .padding()
}
