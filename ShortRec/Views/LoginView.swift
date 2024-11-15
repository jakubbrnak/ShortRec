//
//  LoginView.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
                
                // Title
                Text("Log In")
                    .padding(.top, 120)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .bold()
                
                // Design icons
                HStack {
                    Spacer()
                    Image(systemName: "speaker.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "mic.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.top, 20)

                // Form for user's input
                Form{
                    if !viewModel.errorMessage.isEmpty{
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color.red)
                    }
                    
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    MyButton(title: "Log In",
                        background: .blue) {
                        
                        // Attempt to login
                        viewModel.login()
                        }
                        .padding()
                    
                }
                .scrollContentBackground(.hidden)
                .shadow(color: Color.primary.opacity(0.2), radius: 5)
                
                
                VStack{
                    Text("New around here?")
                    NavigationLink("Create An Account", destination: RegisterView())
                }
                .padding()
                
                Text("Note: Ensure stable internet connection when trying to log in or register")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
    


#Preview {
    LoginView()
}
