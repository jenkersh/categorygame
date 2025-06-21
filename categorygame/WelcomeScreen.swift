import SwiftUI

struct WelcomeScreen: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            LinedPaperBackground()
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text("Welcome to Word Blitz!")
                    .font(.custom("Noteworthy-Bold", size: 40))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Text("Simply list related words that start with a certain letter.")
                    .font(.custom("Noteworthy-Bold", size: 20))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

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

