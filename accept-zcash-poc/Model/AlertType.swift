//
//  AlertType.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/24/21.
//

import Foundation
import SwiftUI
enum AlertType: Identifiable {
    var id: String {
        switch self {
        case .errorAlert:
            return "error"
        case .message:
            return "message"
        }
    }
    
    case errorAlert(_ error: Error)
    case message(_ message: String)
    
    func buildAlert() -> Alert {
        switch self {
        case .errorAlert(let error):
            return Alert(title: Text("Error"), message: Text("\(error.localizedDescription)"), dismissButton: .default(Text("Ok")))
        case .message(let message):
            return Alert(title: Text("Boring Message"), message: Text(message), dismissButton: .default(Text("Dismiss")))
        }
    }
}
