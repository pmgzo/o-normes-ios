//
//  SwiftUIView.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 06/11/2021.
//

import SwiftUI

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct LoginView: View {
  @StateObject private var loginVM = LoginViewModel()
  @EnvironmentObject var authentication: Authentication
  @State var isShowPassword: Bool = true

    var body: some View {
      VStack {
        LogoImage()
        WelcomeText()
        UsernameTextField(username: $loginVM.credentials.email)
        PasswordSecureField(password: $loginVM.credentials.password, isShowPassword: $isShowPassword).padding(.bottom, 20)
        if loginVM.showProgressView {
          ProgressView()
        }
        Button(action: {
          if !loginVM.loginDisabled {
            loginVM.login { success in
              authentication.updateValidation(success: success)
            }
          }
        }, label: { loginVM.showProgressView ? AnyView(ProgressView()) : AnyView(LoginButtonContent()) })
        LabelledDivider(label: "ou").padding()
      }.padding()
        .preferredColorScheme(.light)
        .autocapitalization(.none)
        .alert(item: $loginVM.error) { error in
          Alert(title: Text("Erreur"), message: Text(error.localizedDescription))
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {  
        LoginView()
    }
}

struct LogoImage: View {
  var body: some View {
    Image("Logo")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(height: 200)
      .padding()
  }
}

struct WelcomeText: View {
  var body: some View {
    Text("Bienvenue sur O-Normes !")
      .font(.title2)
      .fontWeight(.semibold)
      .multilineTextAlignment(.center)
      .padding(.bottom, 16)
  }
}

struct UsernameTextField: View {
  @Binding var username: String
  
  var body: some View {
    TextField("Adresse mail", text: $username)
      .padding()
      .background(lightGreyColor)
      .cornerRadius(5.0)
      .keyboardType(.emailAddress)
  }
}

struct PasswordSecureField: View {
  @Binding var password: String
  @Binding var isShowPassword: Bool
  
  var body: some View {
    ZStack(alignment: .trailing) {
      if isShowPassword {
        SecureField("Mot de passe", text: $password)
          .padding()
          .background(lightGreyColor)
          .cornerRadius(5.0)
      } else {
        TextField("Mot de passe", text: $password)
          .padding()
          .background(lightGreyColor)
          .cornerRadius(5.0)
      }
      Button(action: {
        isShowPassword.toggle()
      }) {
        Image(systemName: self.isShowPassword ? "eye.slash" : "eye")
          .foregroundColor(.accentColor)
      }.offset(x: -10, y: 0)
    }
  }
}

struct LoginButtonContent: View {
  var body: some View {
    Text("Connexion")
      .frame(maxWidth: .infinity)
      .font(.headline)
      .foregroundColor(.white)
      .padding()
      .background(Color.accentColor)
      .cornerRadius(15.0)
  }
}

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
      Text(label).foregroundColor(color)
      line
    }
  }
  
  var line: some View {
    VStack { Divider().background(color) }.padding(horizontalPadding)
  }
}

