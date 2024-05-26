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
        // Check if the user is signed in and show appropriate view
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            TabView{
                RecordsView()
                    .tabItem {
                        Label("Records", systemImage: "mic.fill")
                    }
                ProfileView()
                    .tabItem{
                        Label("Profile", systemImage: "person.circle")
                            }
            }
        }
        else{
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
