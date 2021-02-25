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
    // This Generates the QR Image
    var qrImage: Image {
        if let zAddr = self.zAddress, let img = QRCodeGenerator.generate(from: zAddr) {
            return Image(img, scale: 1, label: Text(String(format:NSLocalizedString("QR Code for %@", comment: ""),"\(zAddr)") ))
        } else {
            return Image("zebra_profile")
        }
    }
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 40){
                QRCodeContainer(qrImage: qrImage,
                                badge: Image("QR-zcashlogo"))
                    .frame(width: 150, height: 150, alignment: .center)
                    .layoutPriority(1)
                
                Text("$\(model.request.amount.toZecAmount())")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.white)
                .font(
                    .custom("Zboto", size: 72)
                )
                
                Text("Append Memo With this Code")
                    
                    .foregroundColor(.white)
                    .font(.title2)
                Text(model.request.code)
                    .foregroundColor(.white)
                    .font(.system(size: 72))
                    
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
