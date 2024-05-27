//
//  NetworkMonitor.swift
//  ShortRec
//
//  Created by Jakub Brnák on 26/05/2024.
//

import Network
import Combine

// Class to monitor network connectivity
class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue: DispatchQueue
    
    @Published var isConnected: Bool = false
    
    init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue.global(qos: .background)
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
