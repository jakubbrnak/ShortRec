//
//  RegisterView.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject var viewModel = RegisterViewModel()
    
    var body: some View {
        // Title
        VStack{
            Text("Create New Account")
                .padding(.top, 120)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .bold()
            
            // Form for user's input
            Form{
                if !viewModel.errorMessage.isEmpty{
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
                TextField("Full Name", text: $viewModel.name)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocorrectionDisabled()
                
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(DefaultTextFieldStyle())
                MyButton(title: "Create Account", background: Color.green) {
                    // Start register
                    viewModel.register()
                }
                .padding()
                
            }
            .scrollContentBackground(.hidden)
            .shadow(color: Color.primary.opacity(0.2), radius: 5)
            
            Spacer()
            
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    RegisterView()
}
