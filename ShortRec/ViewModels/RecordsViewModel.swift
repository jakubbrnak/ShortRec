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

class RecordsViewModel: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var fileURL: URL?
    
    @Published var isRecording = false
    
    init() {
        // setupRecorder() // Uncomment if you want to setup the recorder during initialization
    }
    
    func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            print("Audio session set up successfully")
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        let fileName = UUID().uuidString + ".m4a"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentDirectory.appendingPathComponent(fileName)
        print("File URL for recording: \(fileURL!.absoluteString)")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL!, settings: settings)
            audioRecorder?.prepareToRecord()
            print("Audio recorder prepared successfully")
        } catch {
            print("Audio Recorder setup error: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        setupRecorder()
        audioRecorder?.record()
        isRecording = true
        print("Recording started")
    }
    
    func stopRecording() {
        guard isRecording, let recorder = audioRecorder else {
            print("Recording was not in progress or recorder is nil")
            return
        }
        
        recorder.stop()
        audioRecorder = nil // Ensure the recorder is niled after stopping
        isRecording = false
        print("Recording stopped")
        
        
        // Proceed to upload the file to Firebase Storage
        guard let fileURL = fileURL, let user = Auth.auth().currentUser else {
            print("File URL or user not available")
            return
        }
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            print("File size: \(fileSize) bytes")

            if fileSize == 0 {
                print("File is empty, aborting upload.")
                return
            }
        } catch {
            print("Error getting file size: \(error.localizedDescription)")
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("audio/\(user.uid)/\(fileURL.lastPathComponent)")
        print("Starting file upload to Firebase Storage")
        
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading file: \(error.localizedDescription)")
                return
            }
            print("File uploaded successfully")
            
            // Retrieve download URL and store metadata in Firestore
            storageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    print("Error obtaining download URL: \(error?.localizedDescription ?? "")")
                    return
                }
                print("Download URL obtained: \(downloadURL.absoluteString)")
                
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(user.uid).collection("audioRecords").document()
                
                let audioData: [String: Any] = [
                    "showName": "New Record",
                    "id" : UUID().uuidString,
                    "fileName": fileURL.lastPathComponent,
                    "remoteURL": downloadURL.absoluteString,
                    "timestamp": Timestamp()
                ]
                
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
    
    private func deleteLocalFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Successfully deleted local file: \(url.lastPathComponent)")
        } catch {
            print("Error deleting local file: \(error.localizedDescription)")
        }
    }
    
   
}
