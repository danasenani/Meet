import SwiftUI
import Combine

// Language enum
enum Language: String, CaseIterable {
    case english = "en"
    case arabic = "ar"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        }
    }
}

// Localization Manager
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
        }
    }
    
    init() {
        let savedLang = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        self.currentLanguage = Language(rawValue: savedLang) ?? .english
    }
    
    var isArabic: Bool {
        return currentLanguage == .arabic
    }
    
    var layoutDirection: LayoutDirection {
        return isArabic ? .rightToLeft : .leftToRight
    }
}

// All localized strings
struct LocalizedStrings {
    let lang: Language
    
    // Splash Screen
    var letsMeet: String {
        lang == .arabic ? "!لنلتقِ" : "Let's MEET!"
    }
    
    var join: String {
        lang == .arabic ? "انضم" : "JOIN"
    }
    
    var login: String {
        lang == .arabic ? "تسجيل الدخول" : "Login"
    }
    
    // Create Account
    var createAccount: String {
        lang == .arabic ? "إنشاء حساب" : "Create Account"
    }
    
    var name: String {
        lang == .arabic ? "الاسم" : "Name"
    }
    
    var phoneNumber: String {
        lang == .arabic ? "رقم الهاتف" : "Phone Number"
    }
    
    var password: String {
        lang == .arabic ? "كلمة المرور" : "Password"
    }
    
    var communicationMethod: String {
        lang == .arabic ? "طريقة التواصل" : "Communication Method"
    }
    
    var job: String {
        lang == .arabic ? "الوظيفة" : "Job"
    }
    
    var gender: String {
        lang == .arabic ? "الجنس" : "Gender"
    }
    
    var male: String {
        lang == .arabic ? "ذكر" : "Male"
    }
    
    var female: String {
        lang == .arabic ? "أنثى" : "Female"
    }
    
    var signUp: String {
        lang == .arabic ? "التسجيل" : "Sign Up"
    }
    
    var alreadyHaveAccount: String {
        lang == .arabic ? "لديك حساب بالفعل؟" : "Already have an account?"
    }
    
    // Home Screen
    var letsMeetIn: String {
        lang == .arabic ? "لنلتقِ في" : "Let's Meet In"
    }
    
    var riyadh: String {
        lang == .arabic ? "الرياض" : "Riyadh"
    }
    
    var chooseYourEvent: String {
        lang == .arabic ? "اختر الفعالية" : "Choose your event"
    }
    
    // Activities
    var dinner: String {
        lang == .arabic ? "عشاء" : "Dinner"
    }
    
    var coffee: String {
        lang == .arabic ? "قهوة" : "Coffee"
    }
    
    var camping: String {
        lang == .arabic ? "تخييم" : "Camping"
    }
    
    var walk: String {
        lang == .arabic ? "مشي" : "Walk"
    }
    
    var bike: String {
        lang == .arabic ? "دراجة" : "Bike"
    }
    
    var womenOnly: String {
        lang == .arabic ? "للنساء فقط" : "Women-only"
    }
    
    func activityName(_ activity: String) -> String {
        switch activity {
        case "Dinner": return dinner
        case "Coffee": return coffee
        case "Camping": return camping
        case "Walk": return walk
        case "Bike": return bike
        default: return activity
        }
    }
    
    func displayName(activity: String, isWomenOnly: Bool) -> String {
        let activityText = activityName(activity)
        if isWomenOnly {
            return lang == .arabic ? "\(activityText) \(womenOnly)" : "\(womenOnly) \(activityText)"
        }
        return activityText
    }
    
    // Confirm Booking
    var confirmMeeting: String {
        lang == .arabic ? "تأكيد الاجتماع" : "Confirm Meeting"
    }
    
    var seatsAvailable: String {
        lang == .arabic ? "المقاعد المتاحة" : "Seats Available"
    }
    
    var meet: String {
        lang == .arabic ? "التقي" : "Meet"
    }
    
    var cancel: String {
        lang == .arabic ? "إلغاء" : "Cancel"
    }
    
    // Booking Status
    var youreIn: String {
        lang == .arabic ? "!أنت مسجل" : "You're in!"
    }
    
    var tableFull: String {
        lang == .arabic ? "الطاولة ممتلئة" : "Table Full"
    }
    
    var chatToMeet: String {
        lang == .arabic ? "الدردشة للقاء" : "Chat To Meet"
    }
    
    var cancelMeeting: String {
        lang == .arabic ? "إلغاء الاجتماع" : "Cancel Meeting"
    }
    
    // Chat
    var typeMessage: String {
        lang == .arabic ? "...اكتب رسالة" : "Type a message..."
    }
    
    var noMessages: String {
        lang == .arabic ? "!لا توجد رسائل بعد. ابدأ المحادثة" : "No messages yet. Start the conversation!"
    }
    
    // Profile
    var profile: String {
        lang == .arabic ? "الملف الشخصي" : "Profile"
    }
    
    var edit: String {
        lang == .arabic ? "تعديل" : "Edit"
    }
    
    var logout: String {
        lang == .arabic ? "تسجيل الخروج" : "Logout"
    }
    
    var save: String {
        lang == .arabic ? "حفظ" : "Save"
    }
    
    var languageText: String {
        lang == .arabic ? "اللغة" : "Language"
    }
    
    // Feedback
    var feedback: String {
        lang == .arabic ? "التقييم" : "Feedback"
    }
    
    var howWas: String {
        lang == .arabic ? "كيف كان" : "How was"
    }
    
    var okToMeetAgain: String {
        lang == .arabic ? "يمكن اللقاء مجددًا" : "Ok to meet again"
    }
    
    var dontConnectAgain: String {
        lang == .arabic ? "لا تتواصل مجددًا" : "Don't connect again"
    }
    
    var skip: String {
        lang == .arabic ? "تخطي" : "Skip"
    }
    
    var done: String {
        lang == .arabic ? "تم" : "Done"
    }
    
    var thankYou: String {
        lang == .arabic ? "!شكرًا لك" : "Thank You!"
    }
}
