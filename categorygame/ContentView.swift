import SwiftUI
import ConfettiSwiftUI
import StoreKit
import UIKit
import AVFoundation


enum AppTheme: String, CaseIterable, Identifiable {
    case sketch, cyber, party

    var id: String { self.rawValue }

    var backgroundColor: Color {
        switch self {
        case .sketch: return .white
        case .cyber: return Color(red: 0.05, green: 0.05, blue: 0.18)
        case .party: return Color.purple.opacity(0.2)
        }
    }

    var textColor: Color {
        switch self {
        case .sketch: return .black
        case .cyber: return Color(red: 0.4, green: 1, blue: 0.6)
        case .party: return Color(red: 0.956, green: 0.263, blue: 0.576)
        }
    }

    var buttonColor: Color {
        switch self {
        case .sketch: return .black
        case .cyber: return Color(red: 0.4, green: 1, blue: 0.6)
        case .party: return Color(red: 0.956, green: 0.263, blue: 0.576)
        }
    }

    var buttonTextColor: Color {
        switch self {
        case .sketch: return .white
        case .cyber: return .black
        case .party: return .white
        }
    }

    var font: Font {
        switch self {
        case .sketch: return .custom("Noteworthy-Bold", size: 100)
        case .cyber: return .custom("digital-7", size: 110)
        case .party: return .custom("MarkerFelt-Wide", size: 82)
        }
    }

    var buttonFont: Font {
        switch self {
        case .sketch: return .system(size: 20, weight: .light, design: .none)
        case .cyber: return .system(size: 18, weight: .semibold, design: .monospaced)
        case .party: return .system(size: 18, weight: .heavy, design: .rounded)
        }
    }

    var buttonText: String {
        switch self {
        case .sketch: return "Start Game"
        case .cyber: return "EXECUTE GAME"
        case .party: return "New Game! 🎉"
        }
    }
    
    func styledFont(size: CGFloat) -> Font {
            switch self {
            case .sketch: return .custom("Noteworthy-Bold", size: size)
            case .cyber: return .custom("digital-7", size: size)
            case .party: return .custom("MarkerFelt-Wide", size: size)
            }
        }
    
    var cardOverlayOpacity: Double {
        switch self {
        case .sketch: return 0.55
        case .cyber: return 0.1
        case .party: return 0.3
        }
    }
}

struct ContentView: View {
    @AppStorage("theme") private var themeRaw: String = AppTheme.sketch.rawValue
    @AppStorage("generateCount") private var generateCount: Int = 0
    @AppStorage("hasRequestedReview") private var hasRequestedReview: Bool = false
    @AppStorage("soundsEnabled") private var soundsEnabled: Bool = true
    //private var player: AVAudioPlayer?


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
    @State private var isTimeUp = false
    @State private var player: AVAudioPlayer?
    @State private var showWordCountDialog = false
    @State private var showCongratsDialog = false
    @State private var submittedScore = 0
    @State private var wordCountInput = ""
    @State private var dialogScale: CGFloat = 0.5
    @State private var isSharePresented = false



    let categories = [
        "Animals 🐾",
        "Foods 🍔",
        "Countries 🌍",
        "Movies 🎬",
        "Jobs 👷‍♀️",
        "Adjectives ✨",
        "Sports ⚽️",
        "Instruments 🎸",
        "Fruits 🍓",
        "Colors 🎨",
        "Cartoons 📺",
        "Superheroes 🦸‍♂️",
        "Cities 🏙️",
        "Plants 🌿",
        "Hobbies 🎯",
        "Vehicles 🚗",
        //"Ocean Things 🐠",
        "Space 🌌",
        "Games 🎮",
        "TV Shows 📺"
    ]

    let letters = (65...90).compactMap { UnicodeScalar($0).map { String(Character($0)) } }


    var theme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .sketch
    }
    

    // In ContentView.swift

    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 5)
                        gameStateView
                        //Spacer().frame(height: 5)
                        startGameButton
                        Spacer(minLength: 20)
                    }
                    .ignoresSafeArea(.keyboard)
                    .padding()
                }
                .scrollDisabled(true)
                if showCongratsDialog {
                    dialogBackground
                    CongratsDialogView(score: submittedScore, theme: theme) {
                        withAnimation {
                            showCongratsDialog = false
                            wordCountInput = ""
                        }
                    } onShare: {
                        isSharePresented = true
                    }
                    .scaleEffect(dialogScale)
                    .opacity(showCongratsDialog ? 1 : 0)
                }
            }
            .ignoresSafeArea(.keyboard)
            .sheet(isPresented: $showSettings) {
                SettingsView(themeRaw: $themeRaw, soundsEnabled: $soundsEnabled)
                    .presentationDetents([.large])
            }
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
        
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
        
        .confettiCannon(trigger: $confettiCounter, num: 100, colors: [.pink, .yellow, .blue], radius: 400)
        //.overlay(wordCountDialogOverlay)
        .overlay(
            Group {
                if showWordCountDialog {
                    dialogBackground
                        .onTapGesture {
                            triggerTapHaptic()
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }

                    WordCountDialogView(
                        wordCountInput: $wordCountInput,
                        theme: theme,
                        onSkip: {
                            triggerTapHaptic()
                            withAnimation {
                                showWordCountDialog = false
                                wordCountInput = ""
                            }
                        },
                        onSubmit: {
                            triggerTapHaptic()
                            if let score = Int(wordCountInput), score > 0 {
                                submittedScore = score
                                showWordCountDialog = false
                                wordCountInput = ""
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    dialogScale = 0.5
                                    showCongratsDialog = true
                                    withAnimation(.interpolatingSpring(stiffness: 180, damping: 8)) {
                                        dialogScale = 1.0
                                    }
                                }
                            }
                        }
                    )
                    .ignoresSafeArea(.keyboard)
                    .scaleEffect(dialogScale)
                    .transition(.scale)
                }
                
            }
        )

        .sheet(isPresented: $isSharePresented) {
            ShareSheet(activityItems: ["I scored \(submittedScore) in Word Blitz! Can you beat me? https://apps.apple.com/app/id6747693370"])
        }
        
    }
        

    private var backgroundView: some View {
        Group {
            if theme == .sketch {
                LinedPaperBackground().ignoresSafeArea()
            } else {
                theme.backgroundColor.ignoresSafeArea()
            }
        }
    }

    private var gameStateView: some View {
        Group {
            if isGenerating || isTimeUp {
                categoryLetterTimeCard
                Spacer().frame(height: 0.5)
            } else {
                Text("Tap the button to begin")
                    .foregroundColor(theme.textColor)
                    .padding()
            }
        }
    }

    private var startGameButton: some View {
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
    }

    private var wordCountDialogOverlay: some View {
        Group {
            if showWordCountDialog {
                dialogBackground
                WordCountDialogView(
                    wordCountInput: $wordCountInput,
                    theme: theme,
                    onSkip: {
                        triggerTapHaptic()
                        withAnimation {
                            showWordCountDialog = false
                            wordCountInput = ""
                        }
                    },
                    onSubmit: {
                        triggerTapHaptic()
                        if let score = Int(wordCountInput), score > 0 {
                            submittedScore = score
                            showWordCountDialog = false
                            wordCountInput = ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                dialogScale = 0.5
                                showCongratsDialog = true
                                withAnimation(.interpolatingSpring(stiffness: 180, damping: 8)) {
                                    dialogScale = 1.0
                                }
                            }
                        }
                    }
                )
                .scaleEffect(dialogScale)
                .opacity(showWordCountDialog ? 1 : 0)
            }
        }
    }

    private var categoryLetterTimeCard: some View {
        let screenHeight = UIScreen.main.bounds.height
        let totalHeight = max(screenHeight * 0.6, 400)
        let sectionHeight = totalHeight / 3

        return VStack(spacing: 0) {
            labeledSection(title: "CATEGORY", content: currentCategory, font: theme.styledFont(size: 42))
                .frame(height: sectionHeight)

            Divider().background(theme.textColor.opacity(0.5)).padding(.horizontal, 24)

            labeledSection(title: "STARTS WITH", content: currentLetter, font: theme.styledFont(size: 70), blinking: theme == .cyber)
                .frame(height: sectionHeight)

            Divider().background(theme.textColor.opacity(0.5)).padding(.horizontal, 24)

            labeledSection(
                title: "TIME",
                content: isTimeUp ? "Time’s up!" : timeFormatted,
                font: theme.styledFont(size: isTimeUp ? 42 : 55),
                scaleEffect: timerScale
            )
            .frame(height: sectionHeight)
            .background(
                Text("Time’s up!") // invisible placeholder to lock height
                    .font(theme.styledFont(size: 55))
                    .hidden()
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(theme.cardOverlayOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(theme.textColor.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .frame(height: totalHeight)
    }





    private func labeledSection(title: String, content: String, font: Font, blinking: Bool = false, scaleEffect: CGFloat = 1.0) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(theme.textColor.opacity(0.6))

            Spacer()

            HStack {
                Spacer()
                Text(content)
                    .font(font)
                    .foregroundColor(theme.textColor)
                    .opacity(blinking ? blinkOpacity : 1.0)
                    .minimumScaleFactor(0.5)
                    .scaleEffect(scaleEffect)
                Spacer()
            }

            Spacer()
        }
        .ignoresSafeArea(.keyboard)
        .padding()
    }

    
    // Semi-transparent background for dialogs
       var dialogBackground: some View {
           Color.black.opacity(0.4)
               .ignoresSafeArea()
               .ignoresSafeArea(.keyboard)
               .transition(.opacity)
       }
       

    var timeFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startGame() {
        triggerTapHaptic()
        timer?.invalidate()
        isGenerating = true
        isAnimating = true
        isTimeUp = false
        timeRemaining = 120
        animationIndex = 0
        generateCount += 1
        maybeRequestReview()
        currentCategory = categories.randomElement() ?? "Category"
        cycleCategory()
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
    
    func cycleCategory() {
        let cycleCount = 10
        let delay = 0.05

        guard animationIndex < cycleCount else {
            currentCategory = categories.randomElement() ?? "Category"
            animationIndex = 0
            return
        }

        currentCategory = categories.randomElement() ?? "Category"
        animationIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            cycleCategory()
        }
    }



    func popTimerAndStart() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {  // 0.3 second delay before starting pop
            withAnimation(.easeOut(duration: 0.2)) {
                timerScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.2)) {
                    timerScale = 1.0
                }
                startTimer()
            }
        }
    }





    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else if timeRemaining == 1 {
                timeRemaining -= 1
                playSound() // Play sound just before hitting zero
            } else {
                timer?.invalidate()
                isTimeUp = true
                // timeRemaining remains at 0 for display
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dialogScale = 0.5
                    showWordCountDialog = true
                    withAnimation(.interpolatingSpring(stiffness: 180, damping: 8)) {
                        dialogScale = 1.0
                    }
                }

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
        guard generateCount >= 2, !hasRequestedReview else { return }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            hasRequestedReview = true
        }
    }

    func triggerTapHaptic() {
        switch theme {
        case .sketch: UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .cyber: UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .party: UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
    

    func playSound() {
        guard soundsEnabled else { return } // Prevent playing if sound is disabled

        if let url = Bundle.main.url(forResource: "ding", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Error loading sound: \(error)")
            }
        }
    }
    
    struct VisualEffectBlur: UIViewRepresentable {
        var effect: UIVisualEffect?
        
        func makeUIView(context: Context) -> UIVisualEffectView {
            UIVisualEffectView(effect: effect)
        }

        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
            uiView.effect = effect
        }
    }



    
}

struct SettingsView: View {
    @Binding var themeRaw: String
    @Binding var soundsEnabled: Bool
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
                    .onChange(of: themeRaw) { _ in
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred() // ✅ Theme change haptic
                        }
                }
                
                Section(header: Text("Sound")) {
                        Toggle("Enable Sounds", isOn: $soundsEnabled)
                        .onChange(of: soundsEnabled) { _ in
                            UIImpactFeedbackGenerator(style: .light).impactOccurred() // ✅ Toggle haptic
                            }
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

// UIKit share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


@main
struct RandomLetterApp: App {
    var body: some Scene {
        WindowGroup {
            AppEntryView()
        }
    }
}

#Preview {
    ContentView()
}
