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

struct GrayButtonStyle: PrimitiveButtonStyle
{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .onTapGesture {
            configuration.trigger()
        } //https://developer.apple.com/documentation/swiftui/primitivebuttonstyleconfiguration/role
        .padding()
        .font(.system(size: 20, design: .default))
        .foregroundColor(Color.black).background(Color(red: 213/255, green: 213/255, blue: 213/255))
        .cornerRadius(15)
        .frame(maxWidth: .infinity)
        
    }
}


struct deleteButtonStyle: PrimitiveButtonStyle
{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .onTapGesture {
            configuration.trigger()
        } // TODO: graphical chart for normal, cancel, destructive button + import their police (.configuration.role ==) https://developer.apple.com/documentation/swiftui/primitivebuttonstyleconfiguration/role
        .padding()
        .font(.system(size: 20, design: .default))
        .foregroundColor(Color.white).background(Color.red)
        .cornerRadius(15)
        .frame(maxWidth: .infinity)
        
    }
}


struct validateButtonStyle: PrimitiveButtonStyle
{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .onTapGesture {
            configuration.trigger()
        } // TODO: graphical chart for normal, cancel, destructive button + import their police (.configuration.role ==) https://developer.apple.com/documentation/swiftui/primitivebuttonstyleconfiguration/role
        .padding()
        .font(.system(size: 20, design: .default))
        .foregroundColor(Color.white).background(Color.green)
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
                        .stroke(.gray, lineWidth: 0.5))
                        
    }
}

struct CommentTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(50)
            .cornerRadius(20)
            .foregroundColor(.black)
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 0.5))
                        
    }
}
