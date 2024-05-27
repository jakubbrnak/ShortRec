//
//  MyButton.swift
//  ShortRec
//
//  Created by Jakub Brnák on 05/05/2024.
//

import SwiftUI

struct MyButton: View {
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button{
            
            // Action to perform
            action()
        } label: {
            
            // Title and style of the butotn
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
        // Action
    }
}
