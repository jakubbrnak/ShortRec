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
    
    func fetchRecordings() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("audioRecords").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No recordings found or error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            for document in documents {
                if let showName = document.data()["showName"] as? String,
                    let fileName = document.data()["fileName"] as? String,
                   let id = document.data()["id"] as? String,
                   let urlString = document.data()["remoteURL"] as? String,
                   let timestamp = document.data()["timestamp"] as? Timestamp,
                   let remoteURL = URL(string: urlString) {
                    if !self.recordings.contains(where: { $0.remoteURL == remoteURL }) {
                        self.addRecordingToList(showName: showName, id: id, fileName: fileName, remoteURL: remoteURL, timestamp: timestamp)
                    }
                }
            }
        }
    }
    
    private func addRecordingToList(showName: String, id: String, fileName: String, remoteURL: URL, timestamp: Timestamp) {
        let recording = Record(showName: showName, id: id, fileName: fileName, remoteURL: remoteURL, timestamp: timestamp)
        DispatchQueue.main.async {
            self.recordings.append(recording)
        }
    }
    
    
    var player: AVPlayer?
    @Published var currentlyPlayingId: String? = nil
    
    func play(url: URL, id: String) {
        //isPlaying = true
        currentlyPlayingId = id
        player = AVPlayer(url: url)
        player?.play()
    }
    
    func stop() {
        //isPlaying = false
        currentlyPlayingId = nil
        player?.pause()
        player = nil
    }
    
    func delete(id: String, url: URL) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
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
                
                guard let documents = snapshot?.documents else {
                    print("No documents found to delete")
                    return
                }
                
                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting Firestore document: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                // Remove the record from the local array
                                self?.recordings.removeAll { $0.id == id }
                                //newRecordUploaded.send()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func convertTimestampToString(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
}





