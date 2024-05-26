//
//  UserViewModel.swift
//  ShortRec
//
//  Created by Jakub Brnák on 27/05/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage = ""

    private var db = Firestore.firestore()
    private var auth = Auth.auth()

    init() {
        fetchUser()
    }

    func fetchUser() {
        guard let userId = auth.currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }

        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                self?.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                return
            }

            guard let data = document?.data() else {
                self?.errorMessage = "No user data found."
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let user = try JSONDecoder().decode(User.self, from: jsonData)
                DispatchQueue.main.async {
                    self?.user = user
                }
            } catch {
                self?.errorMessage = "Error decoding user data: \(error.localizedDescription)"
            }
        }
    }

    func logout() {
        do {
            try auth.signOut()
            // Navigate to the login screen or perform other necessary actions
            print("User logged out successfully")
        } catch let signOutError as NSError {
            print("Error logging out: %@", signOutError)
        }
    }
}
