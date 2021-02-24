//
//  SellScreen.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/24/21.
//

import SwiftUI
import ZcashLightClientKit

struct SellScreen: View {
    enum Status {
        case ready
        case syncing
        case offline
    }
    
    @EnvironmentObject var model: ZcashPoSModel
    @Environment(\.zcashEnvironment) var zcash: ZcashEnvironment
    @State var alertType: AlertType? = nil
    @State var status: Status = .offline
    @State var progress: Int = 0
    @State var height: BlockHeight = ZcashSDK.SAPLING_ACTIVATION_HEIGHT

    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 20) {
                ZcashLogo()
                switch status {
                case .offline:
                    Button(action: {
                        start()
                    }) {
                        Text("Offline - Tap to Start").foregroundColor(.white)
                    }
                case .ready:
                     Text("Ready! Yay!").foregroundColor(.white)
                case .syncing:
                     Text("Syncing \(progress)% Block: \(height)").foregroundColor(.white)
                }
                
            }
            .onReceive(zcash.synchronizer.progress) { (p) in
                self.progress = Int(p * 100)
            }
            .onReceive(zcash.synchronizer.syncBlockHeight) { (h) in
                self.height = h
            }
        }.onReceive(zcash.synchronizer.status) { (s) in
            switch s {
            case .disconnected, .stopped:
                self.status = .offline
            case .synced:
                self.status = .ready
            case .syncing:
                self.status = .syncing
            }
        }
        .navigationBarTitle(Text("Zcash PoS"), displayMode: .inline)
        .navigationBarHidden(false)
        .onAppear() {
            _zECCWalletNavigationBarLookTweaks()
            start()
        }
        .alert(item: $alertType) { (type) -> Alert in
            type.buildAlert()
        }
    }
    func start() {
        do {
            guard let ivk = model.viewingKey, let bday = model.birthday else {
                throw ZcashPoSModel.PoSError.unableToRetrieveCredentials
            }
            try self.zcash.synchronizer.initializer.initialize(viewingKeys: [ivk], walletBirthday: bday)
            try self.zcash.synchronizer.start()
        } catch {
            self.alertType = AlertType.errorAlert(error)
        }
    }
}

struct SellScreen_Previews: PreviewProvider {
    static var previews: some View {
        SellScreen()
    }
}
