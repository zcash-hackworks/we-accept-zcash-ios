//
//  HomeScreen.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/23/21.
//

import SwiftUI
import ZcashLightClientKit
struct HomeScreen: View {
 
    @Environment(\.zcashEnvironment) var zcash: ZcashEnvironment
    @EnvironmentObject var model: ZcashPoSModel
    @State var alertType: AlertType? = nil

    var body: some View {

        TabView(selection: $model.tabSelection) {
                SellScreen()
                    .tabItem {
                        Label("Sell", systemImage: "shield")
                    }
                    .tag(AppNavigation.Tab.sell)
                ReceivedTransactions()
                    .tabItem {
                        Label("History", systemImage: "square.and.pencil")
                    }
                    .tag(AppNavigation.Tab.received)
                
                SettingsScreen()
                    .tabItem {
                        Label("Settings", systemImage: "list.dash")
                    }
                    .tag(AppNavigation.Tab.settings)
                

            }
        .navigationBarHidden(false)
        .onAppear() {
            _zECCWalletNavigationBarLookTweaks()
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
        .alert(item: $alertType) { (type) -> Alert in
            type.buildAlert()
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
