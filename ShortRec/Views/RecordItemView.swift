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
    
    @State private var selectedRecording: Record?
    @State private var newShowName = ""
    @State var showEditSheet = false
    
    @State private var editSheetID = UUID()
    
    var body: some View {
        Text("Your Records")
            .padding(.top, 20)
            .font(.title) // Make the text bigger
            .frame(maxWidth: .infinity, alignment: .center)
            .bold()

        HStack {
            Text("Swipe down to refresh")
                .font(.subheadline)
                .foregroundColor(.gray)
            Image(systemName: "arrow.down")
                .foregroundColor(.gray)
        }
        .padding(.top, 10)
        List {
                // @State var isPlaying = false
                ForEach(viewModel.recordings) { recording in
                    HStack {
                        VStack{
                            Text(recording.showName)
                                .bold()
                                .offset(x: -10)
                                .onTapGesture {
                                    print("Recording tapped: \(recording.showName)")
                                    selectedRecording = recording
                                    newShowName = recording.showName
                                    print("Selected recording: \(String(describing: selectedRecording?.showName))")
                                   // editSheetID = UUID()
                                    showEditSheet.toggle()
                                    print("Show edit sheet: \(showEditSheet)")
                                }
                            
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
                                    .font(.system(size: 27))
                            }
                            .buttonStyle(PlainButtonStyle()) // Ensure no additional button padding
                            .frame(width: 27, height: 27) // Constrain the button's frame to the icon's size
                            .contentShape(Rectangle())
                        } else{
                            Button(action: {
                                //isPlaying = true
                                viewModel.play(url: recording.remoteURL, id: recording.id)
                            }) {
                                Image(systemName: "play.circle")
                                    .font(.system(size: 27))
                                    .buttonStyle(PlainButtonStyle()) // Ensure no additional button padding
                                    .frame(width: 27, height: 27) // Constrain the button's frame to the icon's size
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle()) // Ensure no additional button padding
                            .frame(width: 27, height: 27) // Constrain the button's frame to the icon's size
                            .contentShape(Rectangle())
                        }
                    }
                    .swipeActions{
                        Button("Delete") {
                            viewModel.delete(id: recording.id, url: recording.remoteURL)
                        }
                        .tint(Color.red)
                        
                    }
                }
                .onDisappear {
                    viewModel.stop()
                }
            }
            .refreshable {
                withAnimation{
                    viewModel.refresh()
                }
            }
            .listStyle(PlainListStyle())
            .sheet(isPresented: $showEditSheet) {
                if let recording = selectedRecording {
                    VStack {
                        TextField("New Show Name", text: $newShowName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Done") {
                            viewModel.updateShowName(id: recording.id, newShowName: newShowName)
                            showEditSheet = false
                        }
                        .padding()
                    }
                    .padding()
                } else{
                    Button("PICA"){}
                }
            }
            //change uuid to force sheet to reconstruct after every selectedrecording change
            .onChange(of: selectedRecording){
                editSheetID = UUID()
            }
        }

}

#Preview {
    RecordItemView()
}
