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

class RecordsViewModel: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var fileURL: URL?
    
    @Published var isRecording = false
    
    init() {
       setupRecorder()
    }
    
    func setupRecorder() {
        
        let session = AVAudioSession.sharedInstance()
           do {
               try session.setCategory(.playAndRecord, mode: .default)
               try session.setActive(true)
           } catch {
               print("Error setting up audio session: \(error.localizedDescription)")
           }
        
        let fileName = UUID().uuidString + ".m4a"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentDirectory.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL!, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch {
            print("Audio Recorder setup error: \(error.localizedDescription)")
        }

    }
    
   func startRecording() {
       audioRecorder?.record()
       isRecording = true
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        // Proceed to upload the file to Firebase Storage
        guard let fileURL = fileURL, let user = Auth.auth().currentUser else { return }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("audio/\(user.uid)/\(fileURL.lastPathComponent)")
        
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
                
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(user.uid).collection("audioRecords").document()
                
                let audioData: [String: Any] = [
                    "fileName": fileURL.lastPathComponent,
                    "url": downloadURL.absoluteString,
                    "timestamp": Timestamp()
                ]
                
                docRef.setData(audioData) { error in
                    if let error = error {
                        print("Error saving metadata: \(error.localizedDescription)")
                    } else {
                        print("Successfully stored metadata in Firestore")
                    }
                }
            }
        }
    }
}
