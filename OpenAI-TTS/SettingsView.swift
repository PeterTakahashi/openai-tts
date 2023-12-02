//
//  SettingsView.swift
//  OpenAI-TTS
//
//  Created by Apple on 2023/11/25.
//

import SwiftUI

struct SettingsView: View {
    var isInitView: Bool = false
    @AppStorage("openAI_APIKey") private var apiKeyInput: String = ""
    @State private var tempApiKey: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("OpenAI API Key")
                .padding(.horizontal)
                .padding(.top)
                .foregroundColor(Color.primary.opacity(0.7))

            TextField("Enter your OpenAI API key", text: $tempApiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onAppear {
                    tempApiKey = apiKeyInput
                }

            Button(action: saveAction) {
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .padding()
        }
    }

    private func saveAction() {
        apiKeyInput = tempApiKey
        if (!apiKeyInput.isEmpty && !isInitView) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    SettingsView()
}
