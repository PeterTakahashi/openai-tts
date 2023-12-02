//
//  MainView.swift
//  OpenAI-TTS
//
//  Created by Apple on 2023/11/25.
//

import SwiftUI
import Foundation
import AVFoundation

struct MainView: View {
    @AppStorage("openAI_APIKey") private var apiKeyInput: String = ""
    @AppStorage("selectedVoice") private var voice: String = "alloy"
    @AppStorage("playbackSpeed") private var speed: Double = 1.0
    @State private var inputText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var audioUrl: URL?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isAudioReady: Bool = false
    @State private var isPlaying: Bool = false
    private var audioPlayerDelegate = AudioPlayerDelegate()
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 15) {
                    TextEditorView(inputText: $inputText, isTextEditorFocused: $isTextEditorFocused, submit: createSpeech)
//                    TextEditor(text: $inputText)
//                        .frame(height: geometry.size.height * (isTextEditorFocused ? 0.7 : 0.5))
//                        .padding(4)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(Color.gray, lineWidth: 1)
//                        )
//                        .padding(.horizontal)
//                        .focused($isTextEditorFocused)
                    
                    if (!isTextEditorFocused) {
                        VStack(alignment: .leading) {
                            Text("Voice")
                                .font(.caption)
                                .padding(.horizontal)
                                .padding(.top)
                                .foregroundColor(Color.primary.opacity(0.7))

                            Picker("Voice", selection: $voice) {
                                Text("Alloy").tag("alloy")
                                Text("Echo").tag("echo")
                                Text("Fable").tag("fable")
                                Text("Onyx").tag("onyx")
                                Text("Nova").tag("nova")
                                Text("Shimmer").tag("shimmer")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                        }
                        VStack(alignment: .leading) {
                            Text("Speed")
                                .font(.caption)
                                .padding(.horizontal)
                                .padding(.top)
                                .foregroundColor(Color.primary.opacity(0.7))
                            Slider(value: $speed, in: 0.25...4.0, step: 0.25)
                                .padding(.horizontal)
                        }
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                                    .scaleEffect(1.5)
                                    .frame(width: 24, height: 24)
                            } else {
                                Button(action: { createSpeech() }) {
                                    Image(systemName: "waveform.circle.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                            if !isSubmitting && isAudioReady {
                                if !isPlaying {
                                    Button(action: {
                                        self.playAudio()
                                    }) {
                                        Image(systemName: "play.circle.fill")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                    }
                                    .buttonStyle(PrimaryButtonStyle())
                                }
                                
                                if isPlaying {
                                    Button(action: {
                                        self.pauseAudio()
                                    }) {
                                        Image(systemName: "pause.circle.fill")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                    }
                                    .buttonStyle(PrimaryButtonStyle())
                                }
                            }
                        }.frame(height: 24)
                    }
                }
                .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                      Image(systemName: "gear").foregroundColor(.primary)
                    }
                )
                .navigationBarTitle("OpenAI Text to speech", displayMode: .inline)
                .padding(.horizontal)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }.accentColor(.primary)
        }
    }
    
    func playAudio() {
        audioPlayer?.play()
        isPlaying = true
    }

    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }

    func createSpeech() {
        if (inputText.isEmpty) {
            return
        }
        self.isAudioReady = false
        guard !apiKeyInput.isEmpty, !inputText.isEmpty else {
            // If API key or input text is empty, process aborts
            alertTitle = "Error"
            alertMessage = "API key and input text are required."
            showAlert = true
            return
        }

        isSubmitting = true

        // URL of the API request
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!

        // Request Header Settings
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKeyInput)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        // Request Body Settings
        let requestBody = [
            "model": "tts-1",
            "input": inputText,
            "voice": voice,
            "speed": speed
        ] as [String : Any]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error: Error during JSON data generation")
            isSubmitting = false
            return
        }

        // Send request using URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false

                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    print("Error: Invalid response from server")
                    return
                }

                if let mimeType = response.mimeType, mimeType == "audio/mpeg", let data = data {
                    DispatchQueue.main.async {
                        if let mimeType = response.mimeType, mimeType == "audio/mpeg" {
                            do {
                                if let player = try? AVAudioPlayer(data: data) {
                                    self.isAudioReady = true
                                        self.audioPlayer = player
                                        self.audioPlayerDelegate.didFinishPlaying = {
                                            self.isPlaying = false
                                        }
                                        self.audioPlayer?.delegate = audioPlayerDelegate
                                        self.audioPlayer?.play()
                                        isPlaying = true
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
}

#Preview("Light mode")  {
    MainView()
}

#Preview("Dark mode") {
    MainView().environment(\.colorScheme, .dark).background(.black)
}
