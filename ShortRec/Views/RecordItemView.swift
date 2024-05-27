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
    
    // State variables for edit record's name sheet
    @State private var selectedRecording: Record? 
    @State private var newShowName = ""
    @State var showEditSheet = false
    @State private var editSheetID = UUID()
    
    // List of emojis which user can assign to the record
    let emojis = ["🔘", "😊", "😢", "😡", "😂", "😱", "❤️", "👍", "👎"]
    
    var body: some View {
        // Page title
        Text("Your Records")
            .padding(.top, 20)
            .font(.title)
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
        
        // List of the user's records loaded from firebase
        List {
                ForEach(viewModel.recordings) { recording in
                    HStack {
                        VStack(alignment: .leading){
                            
                            // Name of the reocrd
                            HStack{
                       
                                Text(recording.showName)
                                    .bold()
                                
                                // Icon to indicate that name is editable
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(Color.primary)
                            }
                            .onTapGesture {
                                // Open editing sheet when record name tapped
                                selectedRecording = recording
                                newShowName = recording.showName
                                showEditSheet.toggle()
                            }
                            
                            // Date and time of creation
                            Text(viewModel.convertTimestampToString(recording.timestamp))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        // Show current emoji and on tap show menu for emoji change
                        Menu {
                             ForEach(emojis, id: \.self) { emoji in
                                 Button(action: {
                                     viewModel.updateEmoji(id: recording.id, newEmoji: emoji)
                                 }) {
                                     Text(emoji)
                                 }
                             }
                         } label: {
                             Text(recording.emoji)
                                 .font(.system(size: 27))
                         }
                        // Show palay/stop button according to the playback state
                        if viewModel.currentlyPlayingId == recording.id {
                            Button(action: {
                                viewModel.stop()
                            }) {
                                Image(systemName: "stop.circle")
                                    .font(.system(size: 27))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 27, height: 27)
                            .contentShape(Rectangle())
                        } else{
                            Button(action: {
                                viewModel.play(url: recording.remoteURL, id: recording.id)
                            }) {
                                Image(systemName: "play.circle")
                                    .font(.system(size: 27))
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(width: 27, height: 27)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 27, height: 27)
                            .contentShape(Rectangle())
                        }
                    }
                    .swipeActions{
                        
                        // Delete record with swipe gesture
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
                // Refresh list whith refresh gesture   
                withAnimation{
                    viewModel.refresh()
                }
            }
            .listStyle(PlainListStyle())
            .sheet(isPresented: $showEditSheet) {
                
                // Show edit sheet when record name clicked
                if let recording = selectedRecording {
                    VStack{
                        Spacer()
                        
                        Text("Edit Record Name")
                            .font(.title)
                            .padding(.top, 20)
                            .bold()
                        HStack {
                            Text("Insert a new name for your record:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                            
                        
                        TextField("New Show Name", text: $newShowName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 8)
                            .padding(.horizontal, 20)
                        
                        // Call function to upload change to db and close sheet
                        Button(action: {
                            viewModel.updateShowName(id: recording.id, newShowName: newShowName)
                            showEditSheet = false
                        }) {
                            Text("Done")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
            }

            // Change uuid to force sheet to reconstruct after every selectedrecording change
            .onChange(of: selectedRecording){
                editSheetID = UUID()
            }
        }
}

#Preview {
    RecordItemView()
}
