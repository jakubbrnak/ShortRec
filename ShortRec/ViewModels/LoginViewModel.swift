//
//  LoginViewModel.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import FirebaseAuth
import Foundation

class LoginViewModel: ObservableObject{ 
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    init() {}
    
    // Try to log in
    func login() {
        guard validate() else{
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password)
    }
    
    // Validate user inputs
    private func validate() -> Bool {
        errorMessage = ""
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else{
            errorMessage = "Please enter valid emial"
            return false
        }
        
        return true
    }
}
