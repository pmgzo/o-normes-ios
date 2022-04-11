//
//  Style.swift
//  Onormes
//
//  Created by gonzalo on 15/03/2022.
//

import Foundation
import SwiftUI

struct ButtonStyle: PrimitiveButtonStyle
{    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .onTapGesture {
            configuration.trigger()
        } // TODO: graphical chart for normal, cancel, destructive button + import their police (.configuration.role ==) https://developer.apple.com/documentation/swiftui/primitivebuttonstyleconfiguration/role
        .padding()
        .font(.system(size: 20, design: .default))
        .foregroundColor(Color.white).background(Color(hue: 246/360, saturation: 0.44, brightness: 0.24, opacity: 1))
        .cornerRadius(15)
        .frame(maxWidth: .infinity)
        
    }
}

struct MeasureTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .cornerRadius(20)
            .foregroundColor(.black)
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1))
                        
    }
}
