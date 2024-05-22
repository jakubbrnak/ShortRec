//
//  ContentView.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            RecordsView()
        }
        else{
            LoginView()
        }
        
    }
}

#Preview {
    ContentView()
}
