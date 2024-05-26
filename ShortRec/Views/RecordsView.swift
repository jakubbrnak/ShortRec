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

        VStack {
            //Show list of user's records
            RecordItemView()
            
            //Button that changes appearence based on the recording session state
            Text(viewModel.isRecording ? "Recording..." : "Hold to Record")
                .padding()
                .foregroundColor(.white)
                .background(viewModel.isRecording ? Color.red : Color.blue)
                .cornerRadius(10)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            //Start recording (only if not already recording)
                            if !viewModel.isRecording{
                                viewModel.startRecording()
                            }
                        }
                        .onEnded { _ in
                            //Stop recording
                            viewModel.stopRecording()
                        }
                )
                .padding(.bottom, 76)
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    RecordsView()
}
