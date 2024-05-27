//
//  Record.swift
//  ShortRec
//
//  Created by Jakub Brnák on 24/05/2024.
//

import Foundation
import Firebase

// Struct which represents one voice record
struct Record: Identifiable, Equatable {
    var showName: String
    let id: String
    let fileName: String
    let remoteURL: URL
    let timestamp: Timestamp
    var emoji: String
}
