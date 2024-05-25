//
//  Record.swift
//  ShortRec
//
//  Created by Jakub Brnák on 24/05/2024.
//

import Foundation
import Firebase

struct Record: Identifiable {
    let showName: String
    let id: String
    let fileName: String
    let remoteURL: URL
    let timestamp: Timestamp
}
