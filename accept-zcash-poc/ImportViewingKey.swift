//
//  ContentView.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/19/21.
//

import SwiftUI
import ZcashLightClientKit
struct ImportViewingKey: View {
    @EnvironmentObject var model: ZcashPoSModel
    @State var ivk: String = ""
    @State var birthday: String = ""
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 30) {
                
                ZcashLogo()
                    
                
                ZcashTextField(
                    title: "Paste a Zcash Viewing Key",
                    subtitleView: AnyView(
                        seedPhraseSubtitle
                    ),
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $ivk,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                
                ZcashTextField(
                    title: "Your Key's Birthday",
                    subtitleView: AnyView(
                        Text.subtitle(text: "If you don't know it, leave it blank. First Sync will take longer.")
                    ),
                    keyboardType: UIKeyboardType.decimalPad,
                    binding: $birthday,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                
                Button(action: {
                    // TODO: import the viewing key and initialize the app
                }) {
                    Text("Import Viewing Key")
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: .zButtonGradient)))
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.4)
            }
            .padding()
        }
        .keyboardAdaptive()
        .animation(.easeInOut)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        
    }
    var isFormValid: Bool {
        self.isValidBirthday(birthday) && model.isValidViewingKey(ivk)
    }
    
    var seedPhraseSubtitle: some View {
        if ivk.isEmpty {
            return Text.subtitle(text: "Your viewing key starts with 'zxviews1'")
        }
        
        if model.isValidViewingKey(ivk) {
            return Text.subtitle(text: "This is a valid Zcash Viewing Key")
        }
        
        return Text.subtitle(text: "Invalid Zcash Viewing Key")
            .foregroundColor(.red)
            .bold()
    }
 
    func isValidBirthday(_ birthday: String) -> Bool {
        
        guard !birthday.isEmpty else {
            return true
        }
        
        guard let b = BlockHeight(birthday) else {
            return false
        }
        
        return b >= ZcashSDK.SAPLING_ACTIVATION_HEIGHT
    }
    
}

extension Text {
    static func subtitle(text: String) -> Text {
        Text(text)
            .foregroundColor(.zLightGray)
            .font(.footnote)
    }
}


extension ZcashPoSModel {
    func isValidViewingKey(_ ivk: String) -> Bool {
        false // TODO: validate the viewing key
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ImportViewingKey()
    }
}
