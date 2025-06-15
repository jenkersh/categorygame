import SwiftUI
import ConfettiSwiftUI
import StoreKit
import UIKit

enum AppTheme: String, CaseIterable, Identifiable {
    case minimalist, cyber, party

    var id: String { self.rawValue }

    var backgroundColor: Color {
        switch self {
        case .minimalist: return .white
        case .cyber: return Color(red: 0.05, green: 0.05, blue: 0.18)
        case .party: return Color.purple.opacity(0.2)
        }
    }

    var textColor: Color {
        switch self {
        case .minimalist: return .black
        case .cyber: return Color(red: 0.4, green: 1, blue: 0.6)
        case .party: return Color(red: 0.956, green: 0.263, blue: 0.576)
        }
    }

    var buttonColor: Color {
        switch self {
        case .minimalist: return .black
        case .cyber: return Color(red: 0.4, green: 1, blue: 0.6)
        case .party: return Color(red: 0.956, green: 0.263, blue: 0.576)
        }
    }

    var buttonTextColor: Color {
        switch self {
        case .minimalist: return .white
        case .cyber: return .black
        case .party: return .white
        }
    }

    var font: Font {
        switch self {
        case .minimalist: return .system(size: 90, weight: .light, design: .none)
        case .cyber: return .custom("digital-7", size: 110)
        case .party: return .custom("MarkerFelt-Wide", size: 82)
        }
    }

    var buttonFont: Font {
        switch self {
        case .minimalist: return .system(size: 24, weight: .light, design: .none)
        case .cyber: return .system(size: 22, weight: .semibold, design: .default)
        case .party: return .custom("MarkerFelt-Wide", size: 24)
        }
    }

    var buttonText: String {
        switch self {
        case .minimalist: return "Start"
        case .cyber: return "RUN"
        case .party: return "Party!  🎉"
        }
    }
}

struct ContentView: View {
    @AppStorage("theme") private var themeRaw: String = AppTheme.minimalist.rawValue
    @AppStorage("generateCount") private var generateCount: Int = 0
    @AppStorage("hasRequestedReview") private var hasRequestedReview: Bool = false

    @State private var currentLetter: String = ""
    @State private var currentCategory: String = ""
    @State private var isGenerating = false
    @State private var showSettings = false
    @State private var confettiCounter: Int = 0
    @State private var blinkOpacity: Double = 1.0
    @State private var timeRemaining: Int = 120
    @State private var timer: Timer? = nil
    @State private var animationIndex: Int = 0
    @State private var isAnimating = false
    @State private var timerHighlight = false
    @State private var timerScale: CGFloat = 1.0



    let categories = ["Animalss", "Foods", "Countries", "Movies", "Jobs", "Adjectives"]
    let letters = (65...90).compactMap { UnicodeScalar($0).map { String(Character($0)) } }


    var theme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .minimalist
    }

    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()
                    if isGenerating {
                        Text("Category: \(currentCategory)")
                            .font(.title2)
                            .foregroundColor(theme.textColor)

                        Text(currentLetter)
                            .font(theme.font)
                            .foregroundColor(theme.textColor)
                            .opacity(theme == .cyber ? blinkOpacity : 1.0)

                        Text("Time: \(timeFormatted)")
                            .font(.title2)
                            .foregroundColor(theme.textColor)
                            .scaleEffect(timerScale)


                    } else {
                        Text("Tap start to begin")
                            .foregroundColor(theme.textColor)
                    }

                    Button(action: startGame) {
                        Text(theme.buttonText)
                            .font(theme.buttonFont)
                            .padding()
                            .frame(width: 200)
                            .background(theme.buttonColor)
                            .foregroundColor(theme.buttonTextColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isAnimating)

                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 24))
                                .foregroundColor(theme.textColor)
                        }
                    }
                }
                .padding()
                .sheet(isPresented: $showSettings) {
                    SettingsView(themeRaw: $themeRaw)
                        .presentationDetents([.large])
                }
            }
        }
        .confettiCannon(trigger: $confettiCounter, num: 100, colors: [.pink, .yellow, .blue], radius: 400)
    }

    var timeFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startGame() {
        triggerTapHaptic()

        // Stop any running timer and reset state
        timer?.invalidate()
        isGenerating = true
        isAnimating = true
        timeRemaining = 120
        animationIndex = 0

        generateCount += 1
        maybeRequestReview()

        // Pick new category and animate letter
        currentCategory = categories.randomElement() ?? "Category"
        animateLetterCycle()
    }


    func animateLetterCycle() {
        let cycleCount = 20
        let delay = 0.05

        guard animationIndex < cycleCount else {
            currentLetter = letters.randomElement() ?? "A"
            isAnimating = false

            if theme == .party {
                confettiCounter += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    popTimerAndStart()
                }
            } else if theme == .cyber {
                blinkAnimation {
                    popTimerAndStart()
                }
            } else {
                popTimerAndStart()
            }
            return
        }

        currentLetter = letters.randomElement() ?? "A"
        animationIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            animateLetterCycle()
        }
    }


    func popTimerAndStart() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {  // 0.3 second delay before starting pop
            withAnimation(.easeOut(duration: 0.3)) {
                timerScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    timerScale = 1.0
                }
                startTimer()
            }
        }
    }





    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isGenerating = false
                timer?.invalidate()
            }
        }
    }

    func blinkAnimation(completion: @escaping () -> Void) {
        let blinkTimes = 3
        let blinkDuration = 0.2
        for i in 0..<blinkTimes {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * blinkDuration * 2) {
                withAnimation(.easeInOut(duration: blinkDuration)) {
                    blinkOpacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + blinkDuration) {
                    withAnimation(.easeInOut(duration: blinkDuration)) {
                        blinkOpacity = 1.0
                    }
                    if i == blinkTimes - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + blinkDuration) {
                            completion()
                        }
                    }
                }
            }
        }
    }

    func maybeRequestReview() {
        guard generateCount >= 10, !hasRequestedReview else { return }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            hasRequestedReview = true
        }
    }

    func triggerTapHaptic() {
        switch theme {
        case .minimalist: UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .cyber: UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .party: UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}

struct SettingsView: View {
    @Binding var themeRaw: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Theme")) {
                    Picker("Theme", selection: $themeRaw) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue.capitalized).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

@main
struct RandomLetterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
