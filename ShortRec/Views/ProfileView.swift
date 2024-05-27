//
//  ProfileView.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var viewModel = ProfileViewModel()

    var body: some View {
            VStack {
                Text("Profile")
                    .padding(.top, 34)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .bold()
                
                // Check if user data were fetched correctly
                if let user = viewModel.user {
                    VStack(spacing: 20) {
                        // User Icon
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .padding(.top, 40)
                        
                        // User Info
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Spacer()
                                Text("Name:")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                              
                                Text(user.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Spacer()
                                Text("Email:")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            
                                Text(user.email)
                                    .font(.subheadline)
                                    .fontWeight(.regular)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Spacer()
                                Text("Joined:")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            
                                Text(user.joined.dateValue(), style: .date)
                                    .font(.subheadline)
                                    .fontWeight(.regular)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .padding(.horizontal)
                        
                        // Log Out Button
                        Button(action: {
                            viewModel.logout()
                        }) {
                            Text("Log Out")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ProgressView()
                        .padding()
                }
            }
            .navigationBarTitle("User Profile", displayMode: .inline)
        }
    }

#Preview {
   ProfileView() 
}
