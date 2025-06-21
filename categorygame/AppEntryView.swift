import SwiftUI

struct AppEntryView: View {
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    @State private var showWritingList = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if hasSeenIntro {
                    ContentView()
                } else if showWritingList {
                    WritingListView {
                        hasSeenIntro = true
                        path.append("content")
                    }
                } else {
                    WelcomeScreen {
                        withAnimation {
                            showWritingList = true
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "content" {
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

