//
//  RecordsViewModel.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import AVFoundation
import FirebaseStorage
import Combine
import UIKit

class RecordsViewModel: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var fileURL: URL?
    
    @Published var isRecording = false
    
    init() {
        requestMicrophoneAccess()
    }
    
    // Setup recorder for new recording session
    func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        // Generate uniqe name for new file
        let fileName = UUID().uuidString + ".m4a"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentDirectory.appendingPathComponent(fileName)
        
        // Settings for audiorecorder object
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // Prepare audiorecorder for recording
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL!, settings: settings)
            audioRecorder?.prepareToRecord()
            print("Audio recorder prepared successfully")
        } catch {
            print("Audio Recorder setup error: \(error.localizedDescription)")
        }
    }
    
    // Start session when user taps and holds recording button
    func startRecording() {
        setupRecorder()
        audioRecorder?.record()
        isRecording = true
        print("Recording started")
    }
    
    // Stop and save when user releases recording button
    func stopRecording() {
        
        // Check if recording was in progress
        guard isRecording, let recorder = audioRecorder else {
            print("Recording was not in progress or recorder is nil")
            return
        }
        
        // Stop recording
        recorder.stop()
        audioRecorder = nil
        isRecording = false
        
        // Upload the file to Firebase Storage
        guard let fileURL = fileURL, let user = Auth.auth().currentUser else {
            print("File URL or user not available")
            return
        }
        
        // Initialize Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference().child("audio/\(user.uid)/\(fileURL.lastPathComponent)")
        
        // Upload file
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading file: \(error.localizedDescription)")
                return
            }

            
            // Retrieve download URL and store metadata in Firestore
            storageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    print("Error obtaining download URL: \(error?.localizedDescription ?? "")")
                    return
                }
                
                // Initialize Firebase Firestore in program
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(user.uid).collection("audioRecords").document()
                
                // Construct metadata dictionary with corresponding values for upload
                let audioData: [String: Any] = [
                    "showName": "New Record",
                    "id" : UUID().uuidString,
                    "fileName": fileURL.lastPathComponent,
                    "remoteURL": downloadURL.absoluteString,
                    "timestamp": Timestamp(),
                    "emoji" : "🔘"
                ]
                
                // Upload data to database
                docRef.setData(audioData) { error in
                    if let error = error {
                        print("Error saving metadata: \(error.localizedDescription)")
                    } else {
                        print("Successfully stored metadata in Firestore")
                        
                        // Delete the local file after successful upload
                        self.deleteLocalFile(at: fileURL)
                        newRecordUploaded.send()
                    }
                }
            }
        }
    }
    
    // Delete temporary local file
    private func deleteLocalFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error deleting local file: \(error.localizedDescription)")
        }
    }
    
    @Published var micPermission = false
    
    func requestMicrophoneAccess() {
        AVAudioApplication.requestRecordPermission { granted in
            if granted {
                self.micPermission = false
            } else {
                self.micPermission = true
                print("Microphone access denied")
            }
        }
    }
    
    func openAppSettings() {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
   
}
