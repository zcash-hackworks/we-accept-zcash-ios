//
//  ZcashLogo.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashLogo: View {

    var fillGradient: LinearGradient {
        LinearGradient(gradient: Gradient(
                                    colors: [Color.zAmberGradient1,
                                             Color.zAmberGradient2]
                                    ),
                       startPoint: UnitPoint(x: 0.5, y: 0),
                       endPoint: UnitPoint(x: 0.5, y: 1.0))
        
    }
    var width: CGFloat = 100
    var body: some View {
        ZcashSymbol()
            .fill(fillGradient)
            .frame(width: width, height: width * 1.05, alignment: .center)
            .padding(width * 0.3)
            .overlay( Ring()
                        .stroke(lineWidth: width * 0.14)
                            .fill(fillGradient)
                            
                            )
        
    }
}

struct ZcashLogo_Previews: PreviewProvider {
    static var previews: some View {
        ZcashLogo()
    }
}
