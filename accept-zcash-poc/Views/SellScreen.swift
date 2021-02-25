//
//  SellScreen.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/24/21.
//

import SwiftUI
import ZcashLightClientKit

struct SellScreen: View {
    
    
    @EnvironmentObject var model: ZcashPoSModel
    @Environment(\.zcashEnvironment) var zcash: ZcashEnvironment
    @State var alertType: AlertType? = nil
    @State var numberString: String = ""
    @State var orderCode: String = ""
    @State var navigation: AppNavigation.Screen? = nil
    var body: some View {
        NavigationView {
            ZStack {
                ZcashBackground()
                VStack(alignment: .center, spacing: 20) {
                    ZcashLogo(width: 50)
                        
                    Spacer()
                    ZcashTextField(title: "Zec Amount To Request",
                                   subtitleView: amountSubtitle,
                                   contentType: nil,
                                   keyboardType: .numberPad,
                                   binding: $numberString,
                                   action: nil,
                                   accessoryIcon: nil,
                                   onEditingChanged: { _ in }, onCommit: {})
                    
                    ZcashTextField(title: "Order Code",
                                   subtitleView: codeSubtitle,
                                   binding: $orderCode) { _ in } onCommit: {}
                    
                    NavigationLink(destination: AppNavigation.Screen.request.buildScreen().environmentObject(model), tag: AppNavigation.Screen.request, selection: $model.navigation) {
                        Button(action: {
                            guard let amount = NumberFormatter.zecAmountFormatter.number(from: numberString)?.doubleValue,
                                  validOrderCode else {
                                self.alertType = AlertType.message("Invalid values!")
                                return
                            }
                            model.currentPayment = ZcashPoSModel.ZECRequest(amount: amount, code: orderCode)
                            model.navigation = .request
                        }) {
                            Text("Request ZEC")
                                .foregroundColor(.black)
                                .zcashButtonBackground(shape: .rounded(fillStyle: .gradient(gradient: .zButtonGradient)))
                                .frame(height: 48)
                        }
                        .disabled(!validForm)
                        .opacity(validForm ? 1.0 : 0.6)
                    }
                }
                .padding(20)
                
            }
            .keyboardAdaptive()
            .navigationBarTitle(Text("Zcash PoS"), displayMode: .inline)
            .navigationBarHidden(false)
            .onAppear() {
                _zECCWalletNavigationBarLookTweaks()
            }
            .alert(item: $alertType) { (type) -> Alert in
                type.buildAlert()
            }
        }
        
    }
    var amountSubtitle: AnyView {
        AnyView(
            Text(validAmount ? "This is a valid amount" : "Invalid Zec amount")
                .foregroundColor(.white)
                .font(.caption)
        )
    }
    
    var codeSubtitle: AnyView {
        AnyView(
            Text(validOrderCode ? "Valid Order code" : "Please enter an order code")
                .foregroundColor(.white)
                .font(.caption)
        )
    }

    var validAmount: Bool {
        guard let amount = NumberFormatter.zecAmountFormatter.number(from: numberString)?.doubleValue else {
            return false
        }
        
        return amount > 0
    }
    
    var validOrderCode: Bool {
        !orderCode.isEmpty && orderCode.count < 6
    }
    
    var validForm: Bool {
        guard validAmount,
              validOrderCode else {
            return false
        }
        return true
    }
    
   
}

struct SellScreen_Previews: PreviewProvider {
    static var previews: some View {
        SellScreen()
    }
}
