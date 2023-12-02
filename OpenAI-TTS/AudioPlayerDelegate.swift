//
//  AudioPlayerDelegate.swift
//  OpenAI-TTS
//
//  Created by Apple on 2023/11/25.
//

import AVFoundation

// AVAudioPlayerDelegateを準拠するクラス
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var didFinishPlaying: (() -> Void)?

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        didFinishPlaying?()
    }
}
