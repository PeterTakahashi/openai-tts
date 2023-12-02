//
//  TextEditorView.swift
//  OpenAI-TTS
//
//  Created by Apple on 2023/11/25.
//

import SwiftUI

struct TextEditorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var inputText: String
    @FocusState.Binding var isTextEditorFocused: Bool
    var submit: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .bottomLeading) {
                    TextEditor(text: $inputText)
                        .focused($isTextEditorFocused)
                    if (!isTextEditorFocused && !inputText.isEmpty) {
                        Button(action: { inputText = "" }) {
                            Image(systemName: "trash")
                                .padding()
                                .foregroundColor(.black)
                        }.padding(4)
                    }
                }
                if (isTextEditorFocused) {
                    Button(action: {
                        Task {
                            isTextEditorFocused.toggle()
                            submit()
                        }
                    }) {
                        Image(systemName: "arrow.forward.circle.fill")
                            .padding()
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? .white : .black )
                    }
                    .padding(4)
                } else if (!inputText.isEmpty) {
                    Button(action: { copyText(text: inputText) }) {
                        Image(systemName: "doc.on.doc")
                            .padding()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .padding(4)
                }
            }
            if inputText.isEmpty {
                placeholderView.onTapGesture {
                    self.isTextEditorFocused = true
                }
            }
            if (inputText.isEmpty && !isTextEditorFocused) {
                HStack {
                    Button(action: {  pasteText() }) {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.white)
                            Text("Paste")
                                .foregroundColor(.white)
                        }
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 5)
                        .background(colorScheme == .dark ? .white : .black)
                        .cornerRadius(5)
                    }
                    Spacer()
                }.padding(.top, 70)
            }
        }
    }
    
    func copyText(text: String) {
        UIPasteboard.general.string = text
    }
    
    @MainActor
    private func pasteText() {
        print("paste")
        if let string = UIPasteboard.general.string {
            inputText = string
            submit()
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        if inputText.isEmpty {
            Text("Enter text")
                .foregroundColor(.gray)
                .padding(.all, 8)
        }
    }
}
