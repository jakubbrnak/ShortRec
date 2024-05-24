//
//  RecordsView.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI

let items = [
    "Interview with Alice",
    "Project Meeting",
    "Lecture on SwiftUI",
    "Team Sync Call",
    "Strategy Planning Session"
]



struct RecordsView: View {
    @StateObject var viewModel = RecordsViewModel()

    var body: some View {
        List(items, id: \.self) { item in
            // Display each string using a Text view
            Text(item)
                .font(.headline) // Adjust font style as needed
                .padding(.vertical, 5) // Add some vertical padding
        }
        .navigationTitle("Records List")
        
        VStack {
            Text(viewModel.isRecording ? "Recording..." : "Hold to Record")
                .padding()
                .foregroundColor(.white)
                .background(viewModel.isRecording ? Color.red : Color.blue)
                .cornerRadius(10)
                .gesture(
                    DragGesture(minimumDistance: 0) // Minimum distance ensures any touch is registered
                        .onChanged { _ in
                     /*       if !viewModel.isRecording {
                                viewModel.isRecording = true
                                print("Started Recording")
                                // Call your ViewModel's startRecording function here
                            } */
                            if !viewModel.isRecording{
                                viewModel.startRecording()
                            }
                        }
                        .onEnded { _ in
                     /*       if viewModel.isRecording {
                                viewModel.isRecording = false
                                print("Stopped Recording")
                                // Call your ViewModel's stopRecording function here
                            } */
                            viewModel.stopRecording()
                        }
                )
            
            Spacer()
        }
        .padding()

    }
}


#Preview {
    RecordsView()
}
