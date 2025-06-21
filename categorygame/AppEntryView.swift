//
//  AppEntryView.swift
//  categorygame
//
//  Created by Jen Kersh on 6/21/25.
//

import SwiftUI

struct AppEntryView: View {
    @State private var showWritingList = false

    var body: some View {
        if showWritingList {
            WritingListView()
        } else {
            WelcomeScreen {
                withAnimation {
                    showWritingList = true
                }
            }
        }
    }
}
