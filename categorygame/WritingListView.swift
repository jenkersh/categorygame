//
//  WritingListView.swift
//  categorygame
//
//  Created by Jen Kersh on 6/21/25.
//

import SwiftUI

struct WritingListView: View {
    let words = ["Aardvark", "Antelope", "Alligator", "Armadillo", "Ape"]
    @State private var revealedWords: [String] = []

    var body: some View {
        ZStack {
            // Lined paper background
            LinedPaperBackground()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {  // Increased spacing for clarity

                // Revealed words list
                ForEach(revealedWords, id: \.self) { word in
                    Text(word)
                        .font(.custom("Noteworthy-Bold", size: 32))
                        .foregroundColor(.black)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .animation(.easeInOut, value: revealedWords)
                }
            }
            .padding(40)
            
            VStack {
                    HStack {
                        Text("For example:")
                            .font(.custom("Noteworthy-Bold", size: 32))
                            .foregroundColor(.gray)
                            .padding(.leading, 40)
                            .padding(.top, 40)
                        Spacer()
                    }
                    Spacer()
                }
            
        }
        .onAppear {
            startWritingAnimation()
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
    WritingListView()
}

//  WelcomeScreen.swift
//  categorygame
//
//  Created by Jen Kersh on 6/15/25.
//

