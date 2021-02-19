//
//  UIKit+extensions.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/19/21.
//

import Foundation
import UIKit
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
