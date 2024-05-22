//
//  ContentViewModel.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import FirebaseAuth
import Foundation

class ContentViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self]_, user in
            DispatchQueue.main.async{
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }
    public var isSignedIn: Bool{
        return Auth.auth().currentUser != nil
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
