//
//  String+Zcash.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit

extension String {
    
    var isValidShieldedAddress: Bool {
        do {
            return try DerivationTool.default.isValidShieldedAddress(self)
        } catch {
            return false
        }
    }
    
    var isValidTransparentAddress: Bool {
        do {
            return try DerivationTool.default.isValidTransparentAddress(self)
        } catch {
            return false
        }
    }
    
    var isValidAddress: Bool {
        self.isValidShieldedAddress || self.isValidTransparentAddress
    }
    
    var shortZaddress: String? {
        guard isValidAddress else { return nil }
        return String(self[self.startIndex ..< self.index(self.startIndex, offsetBy: 8)])
            + "..."
            + String(self[self.index(self.endIndex, offsetBy: -8) ..< self.endIndex])
    }
}
