//
//  GradientTextFieldBackground.swift
//  Directorate
//
//  Created by Dan Wartnaby on 20/04/2022.
//

import SwiftUI

struct GradientTextFieldBackground: TextFieldStyle {
    let symbol: String
    
    // Hidden function to conform to this protocol
    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6.0)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color("TextField_Start"),
                            Color("TextField_End")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .frame(height: 40)
            
            HStack {
                Image(systemName: symbol)
                    .foregroundColor(Color("TextField_Icon"))
                configuration
            }
            .padding(.leading)
            .foregroundColor(.gray)
        }
    }
}
