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
        RecordItemView()
        
        VStack {
            Text(viewModel.isRecording ? "Recording..." : "Hold to Record")
                .padding()
                .foregroundColor(.white)
                .background(viewModel.isRecording ? Color.red : Color.blue)
                .cornerRadius(10)
                .gesture(
                    DragGesture(minimumDistance: 0) // Minimum distance ensures any touch is registered
                        .onChanged { _ in
                            if !viewModel.isRecording{
                                viewModel.startRecording()
                            }
                        }
                        .onEnded { _ in
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
