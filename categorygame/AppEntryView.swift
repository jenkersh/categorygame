import SwiftUI

struct AppEntryView: View {
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    @State private var showWritingList = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            if hasSeenIntro {
                // User already completed onboarding
                ContentView()
            } else if showWritingList {
                WritingListView {
                    // Navigate to ContentView and mark intro as complete
                    hasSeenIntro = true
                    path.append("content")
                }
                .navigationDestination(for: String.self) { value in
                    if value == "content" {
                        ContentView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
            } else {
                WelcomeScreen {
                    withAnimation {
                        showWritingList = true
                    }
                }
            }
        }
    }
}
