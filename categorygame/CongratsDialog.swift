//
//  CongratsDialog.swift
//  categorygame
//
//  Created by Jen Kersh on 6/21/25.
//

import SwiftUI

struct CongratsDialogView: View {
    let score: Int
    let theme: AppTheme
    let onDismiss: () -> Void
    let onShare: () -> Void

    var body: some View {
        let percent: Int = score >= 25 ? 1 : Int(100 - Double(score) / 25.0 * 100)

        return VStack(spacing: 30) {
            Text("Congrats!")
                .font(theme.styledFont(size: 28))
                .foregroundColor(.black)

            (
                Text("Your score is in the top ")
                    .font(theme.buttonFont)
                + Text("\(percent)%")
                    .font(theme.buttonFont.weight(.black))
                + Text(" of scores.")
                    .font(theme.buttonFont)
            )
            .foregroundColor(.black)
            .multilineTextAlignment(.center)


            HStack(spacing: 40) {
                Button("Dismiss", action: onDismiss)
                    .font(theme.buttonFont)
                    .foregroundColor(.gray)

                Button("Share", action: onShare)
                    .font(theme.buttonFont)
                    .foregroundColor(.blue)
            }
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.horizontal, 45)
    }
}
