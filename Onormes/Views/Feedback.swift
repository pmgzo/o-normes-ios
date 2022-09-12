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
    
    var coordinator: UJCoordinator?;
    
    @Environment(\.presentationMode) var presentationMode

//    init(coordinator: UJCoordinator) {
//
//    }
//    init with coordinator

    var body: some View {
        // title
        Text("Envoyez-nous votre feedback").font(.title).multilineTextAlignment(.center)
        
        // Input
        TextField(
          "Ecrivez ici...",
          text: $textInput
        ).padding().frame(height: 300)
        
        Spacer()
        // Button to validate
        Button("Envoyer") {
            APIService().sendFeedback(feedback: textInput)
            presentationMode.wrappedValue.dismiss()

        }.buttonStyle(validateButtonStyle())
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
