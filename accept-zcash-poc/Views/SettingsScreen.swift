//
//  SettingsScreen.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/24/21.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var model: ZcashPoSModel
    @Environment(\.zcashEnvironment) var zcash: ZcashEnvironment
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack {
                ZcashLogo()
                Text("This is where the settings would be")
                    .foregroundColor(.white)
                Button(action: {
                    zcash.synchronizer.stop()
                    model.nuke()
                    try! zcash.nuke()
                    model.navigation = .importViewingKey
                }) {
                    Text("Stop And Nuke")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
        }
        
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
