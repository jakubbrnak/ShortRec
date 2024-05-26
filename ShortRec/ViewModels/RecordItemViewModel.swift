//
//  RecordItemViewModel.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation
import Combine

class RecordItemViewModel: ObservableObject {
    @Published var recordings: [Record] = []
    var cancellables = Set<AnyCancellable>()
    
    init(newRecordUploaded: PassthroughSubject<Void, Never>) {
        
        // Subscribe to the newRecordUploaded subject
        newRecordUploaded
            .sink { [weak self] in
                self?.fetchRecordings()
            }
            .store(in: &cancellables)
        
        // Initial fetch
        fetchRecordings()
    }
    
    // Fuction to fetch user's recording in case of load or refresh
    func fetchRecordings() {
        
        // Check if user is logged in
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        // Initialize db in program
        let db = Firestore.firestore()
        
        // Get desired documents from db
        db.collection("users").document(user.uid).collection("audioRecords").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No recordings found or error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            // Iterate through fetched documents and create local array of recordings for display
            for document in documents {
                if let showName = document.data()["showName"] as? String,
                    let fileName = document.data()["fileName"] as? String,
                   let id = document.data()["id"] as? String,
                   let urlString = document.data()["remoteURL"] as? String,
                   let timestamp = document.data()["timestamp"] as? Timestamp,
                   let emoji = document.data()["emoji"] as? String,
                   let remoteURL = URL(string: urlString) {
                    
                    // Add recording to the display if not already present
                    if !self.recordings.contains(where: { $0.remoteURL == remoteURL }) {
                        self.addRecordingToList(showName: showName, id: id, fileName: fileName, remoteURL: remoteURL, timestamp: timestamp, emoji: emoji)
                    }
                }
            }
        }
    }
    
    // Function for adding new record to the lsit of displayed records
    private func addRecordingToList(showName: String, id: String, fileName: String, remoteURL: URL, timestamp: Timestamp, emoji: String) {
        let recording = Record(showName: showName, id: id, fileName: fileName, remoteURL: remoteURL, timestamp: timestamp, emoji: emoji)

            self.recordings.append(recording)
        
    }
    
    // Initialize audioplayer object for playback
    var player: AVPlayer?
    @Published var currentlyPlayingId: String? = nil
    private var cancellable: AnyCancellable?
    
    // Function for starting playback
    func play(url: URL, id: String) {
        
        // Ensure correct audiosession setting for playback
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error setting up audio session for playback: \(error.localizedDescription)")
        }
        
        // Set current playing playback to ensure correct state of corresponding play/stop button
        currentlyPlayingId = id
        
        // Set url where playing record is stored
        player = AVPlayer(url: url)
        
        // Wait for record to finish and update play/stop button to correct position
        cancellable = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
                    .sink { [weak self] _ in
                        self?.currentlyPlayingId = nil
                    }
        
        // Start record playback
        player?.play()
    }
    
    // Stop record playback
    func stop() {
        currentlyPlayingId = nil
        player?.pause()
        player = nil
    }
    
    // Delete corresponding record in case of swipe gesture event
    func delete(id: String, url: URL) {
        
        // Check if user is logged in
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        // Initialize db in program
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        // Create a reference to the file to delete
        let storageRef = storage.reference(forURL: url.absoluteString)
        
        // Delete the file from Firebase Storage
        storageRef.delete { [weak self] error in
            if let error = error {
                print("Error deleting file from Storage: \(error.localizedDescription)")
                return
            }
            
            // File deleted successfully from Storage, now delete the Firestore document
            db.collection("users").document(user.uid).collection("audioRecords").whereField("remoteURL", isEqualTo: url.absoluteString).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching Firestore document to delete: \(error.localizedDescription)")
                    return
                }
                
                // Check if desired document was found
                guard let documents = snapshot?.documents else {
                    print("No documents found to delete")
                    return
                }
                
                // Delete document from db
                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting Firestore document: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                
                                // Remove the record from the local array
                                self?.recordings.removeAll { $0.id == id }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Helper function to convert Firebase timestamp to string
    func convertTimestampToString(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    // Refresh function that is called when refresh gesture is performed
    func refresh(){
            
            // Empty the recordings list to prevent showing non existing records
            self.recordings = []
            self.fetchRecordings()
    }
    
    // Function to update ShowName when changed by user
    func updateShowName(id: String, newShowName: String) {
        
        // Check if user is logged in
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        // Initialize db in program
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(user.uid).collection("audioRecords")
        
        collectionRef.whereField("id", isEqualTo: id).getDocuments { [weak self] (querySnapshot, error) in
            
            // Check if document was found
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            guard let document = querySnapshot?.documents.first else {
                print("Document with id \(id) not found")
                return
            }
            
            // Update the data in the db and also in local local array
            document.reference.updateData(["showName": newShowName]) { error in
                if let error = error {
                    print("Error updating show name: \(error.localizedDescription)")
                } else {
                    // Update the local recording's show name
                        if let index = self?.recordings.firstIndex(where: { $0.id == id }) {
                            self?.recordings[index].showName = newShowName
                        }
                }
            }
        }
    }
    
    // Function to update emoji
    func updateEmoji(id: String, newEmoji: String) {
        
        // Check if the user is logged in
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        // Initialize db in the program
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(user.uid).collection("audioRecords")
        
        // Find record to change
        collectionRef.whereField("id", isEqualTo: id).getDocuments { [weak self] (querySnapshot, error) in
            
            // Check if document found
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("Document with id \(id) not found")
                return
            }
            
            // Update emoji in db
            document.reference.updateData(["emoji": newEmoji]) { error in
                if let error = error {
                    print("Error updating emoji: \(error.localizedDescription)")
                } else {
                    
                    // Update the local recording's emoji
                    if let index = self?.recordings.firstIndex(where: { $0.id == id }) {
                        self?.recordings[index].emoji = newEmoji
                    }
                }
            }
        }
    }


}
