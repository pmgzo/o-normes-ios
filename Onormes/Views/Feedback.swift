//
//  Feedback.swift
//  Onormes
//
//  Created by gonzalo on 09/09/2022.
//

import Foundation
import SwiftUI

struct FeedbackView: View {
    
    @State private var hasSendFeedback = false
    @State private var textInput: String = ""
    
    @State private var animate: Bool = false

    var coordinator: UJCoordinator?;
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        // title
        Text("Envoyez-nous votre feedback").font(.title).multilineTextAlignment(.center)
        
        TextField(
          "Ecrivez ici...",
          text: $textInput
        ).padding().frame(height: 300)
        
        Spacer()

        Button(action: {
            Task {
                print("va envoyer")

                animate = true
                await APIService().sendFeedback(feedback: textInput)
                animate = false
                presentationMode.wrappedValue.dismiss()
            }
        }){
            if animate {
                LoadingCircle()
            } else {
                Text("Envoyer")
            }
        }
        .modifier(PrimaryButtonStyle1())
    }
}

struct LoadingCircle: View {
    @State private var animate: Bool = false
    
    var body: some View {
        Image("loadingCircle").resizable().frame(width: 20, height: 20)
        .rotationEffect(Angle(degrees: animate ?  360 : 0))
        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: animate)
        .onAppear { animate.toggle() }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
