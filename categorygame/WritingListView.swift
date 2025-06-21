import SwiftUI

struct WritingListView: View {
    let words = ["Aardvark", "Antelope", "Alligator", "Armadillo", "Ape"]

    @State private var revealedWords: [String] = []
    @State private var typedHeader = ""
    @State private var headerFinished = false

    var onLetsGo: () -> Void  // New: lets the parent decide what happens on button tap

    var body: some View {
        ZStack {
            // Lined paper background
            LinedPaperBackground()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                // Typewriter "For example:"
                Text(typedHeader)
                    .font(.custom("Noteworthy-Bold", size: 24))
                    .padding(.top, 40)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // Revealed words list
                ForEach(revealedWords, id: \.self) { word in
                    Text(word)
                        .font(.custom("Noteworthy-Bold", size: 32))
                        .foregroundColor(.black)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .animation(.easeInOut, value: revealedWords)
                }
                .frame(maxWidth: .infinity)

                Spacer()
                Spacer()

                // "Let's go" button
                Button(action: onLetsGo) {
                    Text("Let’s go!")
                        .font(.custom("Noteworthy-Bold", size: 24))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startHeaderTypewriter()
        }
    }

    func startHeaderTypewriter() {
        let fullText = "For example:"
        typedHeader = ""
        headerFinished = false

        for (index, char) in fullText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.07) {
                typedHeader.append(char)

                if index == fullText.count - 1 {
                    headerFinished = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        startWritingAnimation()
                    }
                }
            }
        }
    }

    func startWritingAnimation() {
        for (index, word) in words.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.2) {
                withAnimation {
                    revealedWords.append(word)
                }
            }
        }
    }
}

struct LinedPaperBackground: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                ForEach(0..<Int(geometry.size.height / 40), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    WritingListView {
        print("Let’s go tapped!")
    }
}
