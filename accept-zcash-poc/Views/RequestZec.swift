//
//  RequestZec.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/24/21.
//

import SwiftUI
import ZcashLightClientKit
struct RequestZec: View {
    @EnvironmentObject var model: ZcashPoSModel
    @State var zAddress: String? = nil
    @State var alertType: AlertType? = nil
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 40){
                Text("To This address:")
                    .foregroundColor(.white)
                Text(zAddress ?? "Error Deriving Address")
                    .foregroundColor(.white)
                
                Text("$\(model.request.amount.toZecAmount())")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.white)
                .font(
                    .custom("Zboto", size: 72)
                )
                
                Text("Append Memo With this Code")
                    .foregroundColor(.white)
                Text(model.request.code)
                    .foregroundColor(.white)
                    .font(.title)
            }
        }.navigationTitle("Pay with ZEC")
        .onAppear() {
            do {
                guard let ivk = model.viewingKey else {
                    self.alertType = .errorAlert(ZcashPoSModel.PoSError.unableToRetrieveCredentials)
                    return
                }
                self.zAddress = try DerivationTool.default.deriveShieldedAddress(viewingKey: ivk)
            } catch {
                self.alertType = .errorAlert(error)
            }
        }
        .alert(item: $alertType) { t in
            t.buildAlert()
        }
    }
}

struct RequestZec_Previews: PreviewProvider {
    static var previews: some View {
        RequestZec()
    }
}

extension ZcashPoSModel {
    var request: ZECRequest {
        self.currentPayment ?? ZECRequest.nullRequest
    }
}

extension ZcashPoSModel.ZECRequest {
    static var nullRequest: Self {
        Self(amount: 0, code: "NO CODE")
    }
}
