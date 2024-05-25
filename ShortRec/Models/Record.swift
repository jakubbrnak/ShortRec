//
//  Record.swift
//  ShortRec
//
//  Created by Jakub Brnák on 24/05/2024.
//

import Foundation
import Firebase

struct Record: Identifiable {
    let showname: String
    let id = UUID()
    let name: String
    let localURL: URL
    let timestamp: Timestamp
}
