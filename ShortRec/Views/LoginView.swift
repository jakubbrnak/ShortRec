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
         /*   HStack {
                Image(systemName:"mic.fill")
                           .foregroundColor(.blue)
                    
                Image(systemName:"mic.fill")
                           .foregroundColor(.blue)
                   }*/
            VStack{

                
                Text("Log In")
                    .bold()
          
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
                        //attempt to login
                        viewModel.login()
                        }
                        .padding()
                }
   
                
                VStack{
                    Text("New around here?")
                    NavigationLink("Create An Account", destination: RegisterView())
                }
                .padding(.bottom, 50)
                Spacer()
            
            }
        }
    }
}
    


#Preview {
    LoginView()
}
