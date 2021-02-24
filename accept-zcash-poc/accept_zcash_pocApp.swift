//
//  accept_zcash_pocApp.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/19/21.
//

import SwiftUI
import ZcashLightClientKit

var logger = SimpleLogger(logLevel: .debug, type: SimpleLogger.LoggerType.printerLog)

@main
struct accept_zcash_pocApp: App {
    @StateObject private var model = ZcashPoSModel()
    
    var body: some Scene {
        WindowGroup {
            // we can navigate now!
            NavigationView {
                // and we need to check what our main screen will be. Is it an empty or an already initialized app?
                model.initialScreen()
                    .environmentObject(model)
                    .zcashEnvironment(ZcashEnvironment.default)
                    
            }
        }
    }
}



class ZcashPoSModel: ObservableObject {
    
    enum PoSError: Error {
        case failedToStart(error: Error)
        case unableToRetrieveCredentials
    }
    @Published var tabSelection: AppNavigation.Tab = .history
    @Published var status = AppNavigation.AppStatus.current
    @Published var navigation: AppNavigation.Screen? = nil
   
    @AppStorage("viewingKey") var viewingKey: String?
    @AppStorage("walletBirthday") var birthday: BlockHeight?
    
    var appStatus: AppNavigation.AppStatus {
        guard let vk = self.viewingKey, ((try? DerivationTool.default.isValidExtendedViewingKey(vk)) != nil) else {
            return .empty
        }
        return .initialized
    }
    
   @ViewBuilder func initialScreen() -> some View{
        
        switch appStatus {
        case .empty:
            ImportViewingKey()
        case .initialized:
            HomeScreen()
        }
    }
    
    func nuke() {
        self.birthday = nil
        self.viewingKey = nil
    }
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
    
    enum Screen {
        case importViewingKey
        case home
        
        @ViewBuilder func buildScreen() -> some View {
            switch self {
            case .importViewingKey:
                 ImportViewingKey()
            case .home:
                 HomeScreen()
            }
        }
    }
    
}


extension AppNavigation.Screen: Hashable {}



func _zECCWalletNavigationBarLookTweaks() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.largeTitleTextAttributes = [
        .font : UIFont.systemFont(ofSize: 20),
        NSAttributedString.Key.foregroundColor : UIColor.white
    ]
    
    appearance.titleTextAttributes = [
        .font : UIFont.systemFont(ofSize: 20),
        NSAttributedString.Key.foregroundColor : UIColor.white
    ]
    
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().tintColor = .white
    
    let clearView = UIView()
    clearView.backgroundColor = UIColor.clear
    UITableViewCell.appearance().selectedBackgroundView = clearView
    UITableView.appearance().backgroundColor = UIColor.clear
}
