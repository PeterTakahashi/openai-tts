//
//  ContentView.swift
//  OpenAI-TTS
//
//  Created by Apple on 2023/11/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("openAI_APIKey") private var apiKeyInput: String = ""
    
    var body: some View {
        if apiKeyInput.isEmpty {
            StartView()
                .navigationViewStyle(.stack)
        } else {
            MainView()
                .navigationViewStyle(.stack)
        }
    }
}

#Preview("Light mode")  {
    ContentView()
}

#Preview("Dark mode") {
    ContentView().environment(\.colorScheme, .dark).background(.black)
}
