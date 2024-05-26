//
//  ProfileViewModel.swift
//  ShortRec
//
//  Created by Jakub Brnák on 25/05/2024.
//

import Foundation
import FirebaseAuth


class ProfileViewModel: ObservableObject{
    
    func logout(){
        do {
            try Auth.auth().signOut()
            // Navigate to the login screen or perform other necessary actions
            print("User loged out successfully")
        } catch let signOutError as NSError {
            print("Error logging out: %@", signOutError)
        }
    }
    
}
