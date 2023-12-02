//
//  StartView.swift
//  OpenAI-TTS
//
//  Created by Apple on 2023/11/25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationView {
            NavigationLink {
                SettingsView(isInitView: true)
            } label: {
                WelcomeView()
            }.navigationViewStyle(.stack)
        }.accentColor(.primary)
    }
}

#Preview {
    StartView()
}
