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
  
  var body: some View {
    VStack {
      
      LogoImage()
      
      WelcomeText()
      
      LoginForm().environmentObject(loginVM)
      
      Button(action: {
        if !loginVM.loginDisabled {
          loginVM.login { success in
            authentication.updateValidation(success: success)
          }
        }
      }, label: { loginVM.showProgressView
        ? AnyView(ProgressView())
        : AnyView(LoginButtonContent()) })
      
      LabelledDivider(label: "ou")
      
      Text("Mot de passe oublié").foregroundColor(Color(hex: 0x282359))
    }.padding()
      .preferredColorScheme(.light)
      .autocapitalization(.none)
      .onTapGesture {
        UIApplication.shared.endEditing()
      }
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
      .font(.title3)
      .fontWeight(.semibold)
      .multilineTextAlignment(.center)
      .padding(.bottom, 16)
  }
}

struct UsernameTextField: View {
  @Binding var username: String
  
  var body: some View {
    HStack(alignment: .center) {
      ZStack(alignment: .center) {
        Image(systemName: "envelope.fill")
          .foregroundColor(Color(hex: 0x282359))
      }.frame(width: 40, height: 40, alignment: .center)
      
      TextField("Adresse mail", text: $username)
        .background(lightGreyColor)
        .padding(.bottom)
        .padding(.top)
        .keyboardType(.emailAddress)
        .disableAutocorrection(true)
        .submitLabel(.next)
    }.background(lightGreyColor)
      .cornerRadius(5.0)
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
              .foregroundColor(Color(hex: 0x282359))
              .font(Font.system(size: 22, weight: .regular))
          }.frame(width: 40, height: 40, alignment: .center)
          
          SecureField("Mot de passe", text: $password)
            .padding(.bottom)
            .padding(.top)
            .background(lightGreyColor)
            .submitLabel(.done)
        }.background(lightGreyColor)
          .cornerRadius(5.0)
        
      } else {
        HStack {
          ZStack(alignment: .center) {
            Image(systemName: "lock.fill")
              .foregroundColor(Color(hex: 0x282359))
              .font(Font.system(size: 22, weight: .regular))
          }.frame(width: 40, height: 40, alignment: .center)
          
          TextField("Mot de passe", text: $password)
            .padding(.bottom)
            .padding(.top)
            .background(lightGreyColor)
            .disableAutocorrection(true)
            .submitLabel(.done)
        }.background(lightGreyColor)
          .cornerRadius(5.0)
      }
      Button(action: {
        isShowPassword.toggle()
      }) {
        Image(systemName: self.isShowPassword ? "eye.slash" : "eye")
          .foregroundColor(Color(hex: 0x282359))
      }.offset(x: -10, y: 0)
    }.frame(height: 60)
    
  }
}

struct LoginButtonContent: View {
  var body: some View {
    Text("Connexion")
      .frame(maxWidth: .infinity)
      .font(.headline)
      .foregroundColor(.white)
      .padding()
      .background(Color(hex: 0x282359))
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
