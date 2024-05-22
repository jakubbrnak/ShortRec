//
//  TLButton.swift
//  ToDoListApp
//
//  Created by Jakub Brnák on 22/04/2024.
//

import SwiftUI

struct MyButton: View {
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button{
            //action
            action()
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
            }
        }
    }
}

#Preview {
    MyButton(title: "Value", background: .pink) {
        //action
    }
}
