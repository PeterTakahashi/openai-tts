//
//  WelcomeView.swift
//  OpenAI-TTS
//
//  Created by Apple on 2023/11/25.
//


import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack {
                HStack {
                    Text("OpenAI Text to speech")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview("Light mode") {
    WelcomeView()
}
#Preview("Dark mode") {
    WelcomeView().environment(\.colorScheme, .dark).background(.black)
}
