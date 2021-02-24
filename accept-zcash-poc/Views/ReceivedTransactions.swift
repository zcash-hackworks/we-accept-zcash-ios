//
//  ReceivedTransactions.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/24/21.
//

import SwiftUI

struct ReceivedTransactions: View {
    var body: some View {
        ZStack {
            ZcashBackground()
            Text("This is where our transactions will be")
                .foregroundColor(.white)
        }
    }
}

struct ReceivedTransactions_Previews: PreviewProvider {
    static var previews: some View {
        ReceivedTransactions()
    }
}
