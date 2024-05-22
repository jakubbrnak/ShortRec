//
//  User.swift
//  ShortRec
//
//  Created by Jakub Brnák on 27/03/2024.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
    
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
