//
//  User.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import Foundation
import Firebase

// Struct which represents user
struct User: Codable {
    let id: String
    let name: String
    let email: String
    let joined: Timestamp
    
    // Helper function to serialize data and create dictionary from struct
    func toDictionary() -> [String: Any]? {
           let encoder = JSONEncoder()
           encoder.dateEncodingStrategy = .secondsSince1970

           do {
               let data = try encoder.encode(self)
               let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
               return json
           } catch {
               print("Error converting User to dictionary: \(error)")
               return nil
           }
       }
}
