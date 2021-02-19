//
//  accept_zcash_pocApp.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/19/21.
//

import SwiftUI

@main
struct accept_zcash_pocApp: App {
    @StateObject private var model = ZcashPoSModel()
    var body: some Scene {
        WindowGroup {
            ImportViewingKey()
                .environmentObject(model)
        }
    }
}



class ZcashPoSModel: ObservableObject {
    
    @Published var tabSelection: AppNavigation.Tab = .history
    @Published var status = AppNavigation.AppStatus.current
}


struct AppNavigation {
    enum AppStatus {
        case empty
        case initialized
        
        static var current: AppStatus {
            .empty
        }
    }
    
    enum Tab {
        case receive
        case history
    }
}
