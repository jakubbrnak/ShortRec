//
//  RegisterViewViewModel.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class RegisterViewModel: ObservableObject{
    
    // Variables to store inserted data
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    
    // Variable to store error messages
    @Published  var errorMessage = ""
    
    init() {}
    
    // Create new user using FirebaseAuth
    func register(){
        guard validate() else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else {
                return
            }
            self?.insertUserRecord(id: userId)
        }
    }
    
    // Create user record in Firebase Firestore database
    private func insertUserRecord(id: String){
        let newUser = User(id: id, name: name, email: email, joined: Timestamp())
        
        let db = Firestore.firestore()
        if let userData = newUser.toDictionary() {
            db.collection("users")
                .document(id)
                .setData(userData) { error in
                    if let error = error {
                        print("Error saving user record: \(error)")
                    }
                }
        } else {
            print("Error: Could not convert user to dictionary")
        }
    }
    
    // Validate user inputs
    private func validate() -> Bool{
        errorMessage = ""
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, 
                !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !name.trimmingCharacters(in: .whitespaces).isEmpty
                    
    else {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else{
            errorMessage = "Please enter valid emial"
            return false
        }
        
        guard password.count >= 6 else {
            
            errorMessage = "Password be longer than 5 characters"
            return false
        }
        
        return true
    }
}
