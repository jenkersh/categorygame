import SwiftUI

struct WelcomeScreen: View {
    var onContinue: () -> Void

    @State private var typedText = ""
    @State private var showMainTitle = false
    @State private var showSubtitle = false

    let welcomeText = "Welcome to"

    var body: some View {
        ZStack {
            LinedPaperBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Typewriter line
                Text(typedText)
                    .font(.custom("Noteworthy-Bold", size: 28))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity)

                // "Word Blitz!" pops in
                Text("Word Blitz!")
                    .font(.custom("Noteworthy-Bold", size: 40))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .scaleEffect(showMainTitle ? 1 : 0.5)
                    .opacity(showMainTitle ? 1 : 0)
                    .animation(.interpolatingSpring(stiffness: 120, damping: 10), value: showMainTitle)

                // Subtitle
                Text("Simply list related words that start with a certain letter.")
                    .font(.custom("Noteworthy-Bold", size: 20))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .offset(x: showSubtitle ? 0 : -300)
                    .opacity(showSubtitle ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: showSubtitle)

                Spacer()

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.custom("Noteworthy-Bold", size: 24))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
            }
        }
        .onAppear {
            startTypewriter()
        }
    }

    func startTypewriter() {
        typedText = ""
        showMainTitle = false
        showSubtitle = false

        for (index, char) in welcomeText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.07) {
                typedText.append(char)

                // After typing finishes, trigger next animations
                if index == welcomeText.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showMainTitle = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showSubtitle = true
                    }
                }
            }
        }
    }
}



#Preview {
    WelcomeScreen(onContinue: {})
}


//  WelcomeScreen.swift
//  categorygame
//
//  Created by Jen Kersh on 6/15/25.
//

