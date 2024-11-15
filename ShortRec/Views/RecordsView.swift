//
//  RecordsView.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI

struct RecordsView: View {
    @StateObject var viewModel = RecordsViewModel() 
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        VStack {
            if networkMonitor.isConnected {
                VStack {
                    // Show list of user's records
                    RecordItemView()
                    
                    // Button that changes appearance based on the recording session state
                    Text(viewModel.isRecording ? "Recording..." : "Hold to Record")
                        .padding()
                        .foregroundColor(.white)
                        .background(viewModel.isRecording ? Color.red : Color.blue)
                        .cornerRadius(10)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    // Start recording (only if not already recording)
                                    if !viewModel.isRecording {
                                        viewModel.startRecording()
                                    }
                                }
                                .onEnded { _ in
                                    // Stop recording
                                    viewModel.stopRecording()
                                }
                        )
                        .padding(.bottom, 76)
                    
                    Spacer()
                }
                .padding()
            } else {
                VStack {
                    Image(systemName: "wifi.slash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("No internet connection. Please reconnect.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .alert(isPresented: $viewModel.micPermission) {
                    Alert(
                        title: Text("Microphone Access Denied"),
                        message: Text("Please enable microphone access in Settings."),
                        primaryButton: .default(Text("Open Settings"), action: {
                            viewModel.openAppSettings()
                        }),
                        secondaryButton: .cancel()
                    )
                }
    }
}

#Preview {
    RecordsView()
}
