//
//  requestMic.swift
//  ShortRec
//
//  Created by Jakub Brnák on 27/05/2024.
//

import Foundation
import SwiftUI
import AVFoundation

func requestMicrophoneAccess() {
    AVAudioApplication.requestRecordPermission { granted in
        if granted {
            print("Microphone access granted")
        } else {
            print("Microphone access denied")
        }
    }
}

