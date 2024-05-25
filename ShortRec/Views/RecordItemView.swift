//
//  RecordItemView.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI
import AVKit
import Combine

struct RecordItemView: View {
    @StateObject var viewModel = RecordItemViewModel(newRecordUploaded: newRecordUploaded)
    
    
    var body: some View {
        List {
           // @State var isPlaying = false
            ForEach(viewModel.recordings) { recording in
                HStack {
                    VStack{
                        Text(recording.showname)
                            .bold()
                            .offset(x: -10)
                        Text(viewModel.convertTimestampToString(recording.timestamp))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                    }
                    Spacer()
                    if viewModel.currentlyPlayingId == recording.id {
                        Button(action: {
                           // isPlaying = false
                            viewModel.stop()
                        }) {
                            Image(systemName: "stop.circle")
                        }
                    } else{
                        Button(action: {
                            //isPlaying = true
                            viewModel.play(url: recording.localURL, id: recording.id)
                        }) {
                            Image(systemName: "play.circle")
                        }
                    }
                }
                .swipeActions{
                    Button("Delete") {
                        viewModel.delete(id: recording.id, url: recording.localURL)
                    }
                    .tint(Color.red)
                    
                }
            }
            .onDisappear {
                viewModel.stop()
            }
        }
    }
}

#Preview {
    RecordItemView()
}
