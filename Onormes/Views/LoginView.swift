//
//  SwiftUIView.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 06/11/2021.
//

import SwiftUI

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
/**
 This is the LoginView structure where the user have to authenticate himself to access to the application
 This class contains the class **LoginForm**. It sends to the LoginForm class the state object **loginVM** to retrieve what the user has typed.
 
 */
struct LoginView: View {
    @StateObject private var loginVM = LoginViewModel()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authentication: Authentication

    @State private var pageIndex = 0
  
  var body: some View {
      VStack {
          
          VStack {
              LogoImage()
              
              if pageIndex == 0 {
                  WelcomeText()
              }
              else {
                  Text("Lancer l'application en mode offline")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
              }
              
              if pageIndex == 0 {
                  VStack {

                    LoginForm().environmentObject(loginVM)
                    
                    Button(action: {
                      if !loginVM.loginDisabled {
                        loginVM.login { success in
                          authentication.updateValidation(success: success)
                        }
                      }
                    }, label: { loginVM.showProgressView
                      ? AnyView(LoadingCircle())
                        : AnyView(LoginButtonContent())
                    }).modifier(PrimaryButtonStyle1())
                    
                    LabelledDivider(label: "ou")
                    
                      Text("Mot de passe oublié")
                          .font(.system(size: 18, design: .default))
                          .foregroundColor(Color(hex: "29245A"))
                  }.padding()
                    .preferredColorScheme(.light)
                    .autocapitalization(.none)
                    .onTapGesture {
                      UIApplication.shared.endEditing()
                    }
                    .alert(item: $loginVM.error) { error in
                      Alert(title: Text("Erreur"), message: Text(error.localizedDescription))
                    }
                    .transition(.slide)
              }
              else {
                  Button("Mode offline") {
                      print("here")
                      authentication.startModeOffline()
                      appState.offlineModeActivated = true
                  }.modifier(SecondaryButtonStyle1())
                  //Text("SecondView")
                    .transition(AnyTransition.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading))) //.backslide
              }
              
          }.frame(maxWidth: .infinity, maxHeight: .infinity)
          .animation(.default, value: pageIndex)
      
          Spacer()
          HStack {
              if pageIndex == 0 {
                  Image(systemName: "circle.fill")
                      .resizable()
                      .frame(width: 5, height: 5)
                      .foregroundColor(Color(hue: 246/360, saturation: 0.44, brightness: 0.24, opacity: 1))
                  Image(systemName: "circle")
                      .resizable()
                      .frame(width: 5, height: 5)
                      .foregroundColor(Color(hue: 246/360, saturation: 0.44, brightness: 0.24, opacity: 1))
              } else {
                  Image(systemName: "circle").resizable()
                      .frame(width: 5, height: 5)
                      .foregroundColor(Color(hue: 246/360, saturation: 0.44, brightness: 0.24, opacity: 1))
                  Image(systemName: "circle.fill").resizable()
                      .frame(width: 5, height: 5)
                      .foregroundColor(Color(hue: 246/360, saturation: 0.44, brightness: 0.24, opacity: 1))
              }
          }
      }
      .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
        .onEnded({ value in
            if value.translation.width < 0 {
                // right
                if pageIndex == 0 {
                    pageIndex = 1
                }
            }

            if value.translation.width > 0 {
                // left
                if pageIndex == 1 {
                    pageIndex = 0
                }
            }
        }))
  }
    
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
/**
 This class display both username and password forms in the **LoginView** page.
 */
struct LoginForm: View {
  enum Field: Hashable {
    case emailAddress
    case passwordField
  }
  
  @FocusState private var focusedField: Field?
  @EnvironmentObject var loginVM: LoginViewModel
  
  var body: some View {
    UsernameTextField(username: $loginVM.credentials.email).focused($focusedField, equals: .emailAddress)
      .onSubmit {
        focusedField = .passwordField
      }
    
    PasswordSecureField(password: $loginVM.credentials.password).focused($focusedField, equals: .passwordField).padding(.bottom)
    
  }
}

struct LogoImage: View {
  var body: some View {
    Image("Logo")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(height: 200)
  }
}

struct WelcomeText: View {
  var body: some View {
    Text("Bienvenue sur O-Normes !")
          .font(.system(size: 25))
          .foregroundColor(Color(hex: "29245A"))
          .multilineTextAlignment(.center)
  }
}

struct UsernameTextField: View {
  @Binding var username: String
  
  var body: some View {
    HStack(alignment: .center) {
      ZStack(alignment: .center) {
        Image(systemName: "envelope.fill")
          .foregroundColor(Color(hex: "29245A"))
      }.frame(width: 40, height: 40, alignment: .center)
      
      TextField("Adresse mail", text: $username)
        .padding(.bottom, 10)
        .padding(.top, 10)
        .font(Font.system(size: 18))
        .foregroundColor(Color(hex: "29245A"))
        .keyboardType(.emailAddress)
        .disableAutocorrection(true)
        .submitLabel(.next)
    }.background(.white)
      .cornerRadius(70)
      .overlay(RoundedRectangle(cornerRadius: 70)
          .stroke(Color(hex: "29245A"), lineWidth: 2))
  }
}

struct PasswordSecureField: View {
  @Binding var password: String
  @State var isShowPassword: Bool = true
  
  var body: some View {
    ZStack (alignment: .trailing) {
      if isShowPassword {
        HStack(alignment: .center){
          ZStack(alignment: .center) {
            Image(systemName: "lock.fill")
              .foregroundColor(Color(hex: "29245A"))
              .font(Font.system(size: 19, weight: .regular))
          }.frame(width: 40, height: 40, alignment: .center)
          
          SecureField("Mot de passe", text: $password)
            .padding(.bottom, 10)
            .padding(.top, 10)
            .foregroundColor(Color(hex: "29245A"))
            .submitLabel(.done)
        }.background(.white)
              .cornerRadius(70)
              .overlay(RoundedRectangle(cornerRadius: 70)
                  .stroke(Color(hex: "29245A"), lineWidth: 2))
      } else {
        HStack {
          ZStack(alignment: .center) {
            Image(systemName: "lock.fill")
              .foregroundColor(Color(hex: "29245A"))
              .font(Font.system(size: 19, weight: .regular))
          }.frame(width: 40, height: 40, alignment: .center)
          
          TextField("Mot de passe", text: $password)
            .padding(.bottom, 10)
            .padding(.top, 10)
            .font(Font.system(size: 18))
            .foregroundColor(Color(hex: "29245A"))
            .disableAutocorrection(true)
            .submitLabel(.done)
            
        }.background(.white)
          .cornerRadius(70)
          .overlay(RoundedRectangle(cornerRadius: 70)
              .stroke(Color(hex: "29245A"), lineWidth: 2))

      }
      Button(action: {
        isShowPassword.toggle()
      }) {
        Image(systemName: self.isShowPassword ? "eye.slash" : "eye")
          .foregroundColor(Color(hex: "29245A"))
      }.offset(x: -10, y: 0)
    }.frame(height: 60)
    
  }
}

struct LoginButtonContent: View {
  var body: some View {
      Text("Connexion")
//      .frame(maxWidth: .infinity)
//      .font(.headline)
//      .foregroundColor(.white)
//      .padding()
//      .background(Color(hex: 0x282359))
//      .cornerRadius(15.0)
  }
}

/**
 
 Class to build spaced label component

 **Constructor**:
 ```swift
 init(label: String, horizontalPadding: CGFloat = 20, color: Color = .gray)
 ```
 **Parameters:**
 - label: string label
- horizontalPadding: the wanted spaces around the label
- color: text's color
 */

struct LabelledDivider: View {
  
  let label: String
  let horizontalPadding: CGFloat
  let color: Color
  
  init(label: String, horizontalPadding: CGFloat = 20, color: Color = .gray) {
    self.label = label
    self.horizontalPadding = horizontalPadding
    self.color = color
  }
  
  var body: some View {
    HStack {
      line
        Text(label).font(.system(size: 18)).foregroundColor(color)
      line
    }
  }
  
  var line: some View {
    VStack { Divider().background(color) }.padding(horizontalPadding)
  }
}
