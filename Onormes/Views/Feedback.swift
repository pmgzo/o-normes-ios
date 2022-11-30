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
    
    @State private var animateButton: Bool = false
    @State private var displayErrorMessage: Bool = false;
    @State var requestError: RequestError?;

    var coordinator: UJCoordinator?;
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        // title
        ReturnButtonWrapper {
            Text("Envoyez-nous votre feedback").font(.title).multilineTextAlignment(.center)
            
            TextField(
              "Ecrivez ici...",
              text: $textInput
            ).padding().frame(height: 300)
            
            Spacer()
            
            Button(action: {
                Task {
                    do {
                        animateButton = true
                        try await  APIService().sendFeedback(feedback: textInput)
                    } catch ServerErrorType.internalError(let reason) {
                        animateButton = false
                        requestError = RequestError(errorDescription: reason)
                        displayErrorMessage = true
                        return
                    } catch {
                        animateButton = false
                        requestError = RequestError(errorDescription: "Erreur interne")
                        displayErrorMessage = true
                        return
                    }
                    
                    animateButton = false
                    presentationMode.wrappedValue.dismiss()
                }
            }){
                if animateButton {
                    LoadingCircle()
                } else {
                    Text("Envoyer")
                }
            }
            .modifier(PrimaryButtonStyle1())
        }
        .alert(
            isPresented: $displayErrorMessage, error: requestError,
           actions: { errorObject in
                Button("Ok") {
                    requestError = nil
                    displayErrorMessage = false
                }
            },
            message: { errorObject
            in
                Text(errorObject.errorDescription)
            }
        )
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
