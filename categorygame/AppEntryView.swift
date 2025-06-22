import SwiftUI

struct AppEntryView: View {
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if hasSeenIntro {
                    ContentView()
                } else {
                    WelcomeScreen {
                        // Navigate to WritingListView by pushing to the stack
                        path.append("writingList")
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "writingList":
                    WritingListView {
                        // When done, mark intro seen and navigate to ContentView
                        hasSeenIntro = true
                        path.append("content")
                    }
                case "content":
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                default:
                    EmptyView()
                }
            }
        }
    }
}


