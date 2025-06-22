//
//  WordCountDialog.swift
//  categorygame
//
//  Created by Jen Kersh on 6/21/25.
//

import SwiftUI

struct WordCountDialogView: View {
    @Binding var wordCountInput: String
    let theme: AppTheme
    let onSkip: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("How many words did you get?")
                .font(theme.styledFont(size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextField("Enter Number", text: $wordCountInput)
                .keyboardType(.numberPad)
                .padding(14)
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .cornerRadius(10)
                .frame(width: 140)
                .onChange(of: wordCountInput) { newValue in
                    let digitsOnly = newValue.filter { $0.isNumber }
                    wordCountInput = String(digitsOnly.prefix(4))
                }

            HStack(spacing: 32) {
                Button("Skip", action: onSkip)
                    .font(theme.buttonFont)
                    .foregroundColor(.gray)

                Button("Submit", action: onSubmit)
                    .font(theme.buttonFont)
                    .foregroundColor(.blue)
            }
            .padding(.top, 8)
            .ignoresSafeArea(.keyboard)
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.horizontal, 45)
    }
}
