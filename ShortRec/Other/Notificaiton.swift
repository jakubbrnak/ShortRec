//
//  Notificaiton.swift
//  ShortRec
//
//  Created by Jakub Brnák on 24/05/2024.
//

import Foundation
import Combine

// Publisher that signals when new record is uploaded
let newRecordUploaded = PassthroughSubject<Void, Never>()
