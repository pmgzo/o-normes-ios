//
//  Style.swift
//  Onormes
//
//  Created by gonzalo on 15/03/2022.
//

import Foundation
import SwiftUI

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

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

struct PrimaryButtonStyle: PrimitiveButtonStyle
{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .onTapGesture {
            configuration.trigger()
        } // TODO: graphical chart for normal, cancel, destructive button + import their police (.configuration.role ==) https://developer.apple.com/documentation/swiftui/primitivebuttonstyleconfiguration/role
        .frame(width: 300)
        .padding([.top, .bottom], 10)
        .font(.system(size: 20, design: .default))
        .foregroundColor(Color.white).background(Color(hex: "29245A"))
        .cornerRadius(70)
    }
}

struct SecondaryButtonStyle: PrimitiveButtonStyle
{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .onTapGesture {
            configuration.trigger()
        } // TODO: graphical chart for normal, cancel, destructive button + import their police (.configuration.role ==) https://developer.apple.com/documentation/swiftui/primitivebuttonstyleconfiguration/role
        .frame(width: 300)
        .padding([.top, .bottom], 8)
        .font(.system(size: 20, design: .default))
        .foregroundColor(Color(hex: "29245A"))
        .cornerRadius(70)
        .frame(maxWidth: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 70)
            .stroke(Color(hex: "29245A"), lineWidth: 3))
    }
}


struct LinkStyle: PrimitiveButtonStyle
{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .onTapGesture {
            configuration.trigger()
        } // TODO: graphical chart for normal, cancel, destructive button + import their police (.configuration.role ==) https://developer.apple.com/documentation/swiftui/primitivebuttonstyleconfiguration/role
        .padding()
        .font(.system(size: 16, design: .default))
        .foregroundColor(Color(hex: "29245A")).background(Color.white)
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct PrimaryButtonStyle1: ViewModifier {
    var size: Float
    init() {
        size = 300.0
    }
    init(size: Int) {
        self.size = Float(size)
    }
    func body(content: Content) -> some View {
        HStack {
            content
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 10)
            .font(.system(size: 18, design: .default))
            .foregroundColor(Color.white).background(Color(hex: "29245A"))
            .cornerRadius(70)
        }.frame(width: CGFloat(size))
    }
}

struct PrimaryDisabledButtonStyle1: ViewModifier {
    var size: Float
    init() {
        size = 300.0
    }
    init(size: Int) {
        self.size = Float(size)
    }
    func body(content: Content) -> some View {
        HStack {
            content
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 10)
            .font(.system(size: 18, design: .default))
            .foregroundColor(Color.white).opacity(0.5)
            .background(Color(hex: "29245A")).opacity(0.5)
            .cornerRadius(70)
        }.frame(width: CGFloat(size))
    }
}

struct SecondaryButtonStyle1: ViewModifier {
    var size: Float
    init() {
        size = 300.0
    }
    init(size: Int) {
        self.size = Float(size)
    }
    func body(content: Content) -> some View {
        HStack {
            content
            .frame(width: CGFloat(size))
            .padding([.top, .bottom], 9)
            .font(.system(size: 18, design: .default))
            .foregroundColor(Color(hex: "29245A"))
            .background(.white)
            .cornerRadius(70)
            .overlay(RoundedRectangle(cornerRadius: 70)
                .stroke(Color(hex: "29245A"), lineWidth: 3))
        }.frame(width: CGFloat(size))
    }
}



struct Header1: ViewModifier {
    var alignment: Alignment;
    
    init(alignment: Alignment = .leading) {
        self.alignment = alignment
    }
    func body(content: Content) -> some View {
        HStack {
            Spacer().frame(width: 30)
            content
                .font(.system(size: 30))
                .foregroundColor(Color(hex: "29245A"))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: self.alignment)
    }
}

struct Header2: ViewModifier {
    var alignment: Alignment;
    
    init(alignment: Alignment = .leading) {
        self.alignment = alignment
    }
    func body(content: Content) -> some View {
        HStack {
            Spacer().frame(width: 30)
            content
                .font(.system(size: 25))
                .foregroundColor(Color(hex: "29245A"))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: self.alignment)
    }
}

struct Header3: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20))
            .foregroundColor(Color(hex: "29245A"))
    }
}

struct DescriptionText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15))
            .foregroundColor(Color(hex: "CABFBF"))
    }
}

// Components

struct RadioButton: View {

    let id: Bool
    let callback: (Bool)->()
    let selectedID : Bool

    init(
        _ id: Bool,
        callback: @escaping (Bool)->(),
        selectedID: Bool,
        size: CGFloat = 20,
        color: Color = Color.primary,
        textSize: CGFloat = 14
        ) {
        self.id = id
        self.selectedID = selectedID
        self.callback = callback
    }

    var body: some View {
        Button(action:{
            self.callback(self.id)
        }) {
            HStack(alignment: .center) {
                //Image(systemName: self.selectedID == self.id ? "largecircle.fill.circle" : "circle")
                Image(self.selectedID == self.id ? "FilledRadioButton" : "EmptyRadioButton")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color(hex: "29245A"))

                Text(id == true ? "Oui" : "Non")
                    .font(Font.system(size: 18)).foregroundColor(Color(hex: "838383"))
            }
        }
    }
}

struct BooleanRadioButtons: View {

    var value: Binding<Bool>;
    
    init(value: Binding<Bool>) {
        self.value = value
    }

    var body: some View {
        VStack {
            HStack {
                RadioButton(true, callback: self.radioGroupCallback, selectedID: self.value.wrappedValue)
                Spacer().frame(width: 50)
                RadioButton(false, callback: self.radioGroupCallback, selectedID: self.value.wrappedValue)
            }
        }
    }

    func radioGroupCallback(val: Bool) {
        self.value.wrappedValue = val
    }
}

struct CheckBox: View {
    let filled: Bool
    init(filled: Bool) {
        self.filled = filled
    }
    var body: some View {
        Image(self.filled ? "FilledCheckBox" : "EmptyCheckBox")
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
    }
}

struct AddStageButton: View {
    let action: () -> Void;
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: "plus").resizable().foregroundColor(.white).frame(width: 10, height: 10).padding()
        }.frame(width: 45, height: 45)
            .background(Color(hex: "29245A"))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
    }
    
}

struct BooleanRadioButtons_Preview: PreviewProvider {
      static var previews: some View {
          //BooleanRadioButtons(value: .constant(true))
          VStack {
              Button("Primary Button") {
                  print("test")
              }
              .buttonStyle(PrimaryButtonStyle())
              
              //DisabledButton("Page suivante")

              Button("Primary Button") {
                  print("test")
              }
              .modifier(PrimaryButtonStyle1(size: 300))
              
              Button("Disabled") {
                  print("test")
              }
              .modifier(PrimaryDisabledButtonStyle1(size: 300))

              
              HStack {
                  Button("Secondary button") {
                      print("test")
                  }
                  .buttonStyle(SecondaryButtonStyle())
              }
              Button("Secondary button") {
                  print("test")
              }
              .modifier(SecondaryButtonStyle1(size: 200))
              
              Button(action: {
                  print("test")
              }) {
                  Image(systemName: "plus").resizable().foregroundColor(.white).frame(width: 10, height: 10).padding()
              }.frame(width: 45, height: 45)
                  .background(Color(hex: "29245A"))
                  .clipShape(Circle())
                  .shadow(color: .black, radius: 5, x: 0, y: 3)
          
              AddStageButton(action: {() -> Void in
                  print("cous")
              })
          }
      }
}



