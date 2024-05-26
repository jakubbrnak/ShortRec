//
//  ProfileView.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Spacer()
            MyButton(
                title: "Log Out",
                background:.red,
                action:viewModel.logout)
                .padding()
        }
        
    }
}

#Preview {
    ProfileView()
}
