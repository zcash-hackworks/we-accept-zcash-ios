//
//  ContentView.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/19/21.
//

import SwiftUI
import ZcashLightClientKit
struct ContentView: View {
    var body: some View {
        Text("Hello, Zcash \(ZcashSDK.isMainnet ? "MainNet" : "TestNet")")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
