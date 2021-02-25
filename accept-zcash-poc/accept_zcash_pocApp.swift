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
            
            //we need to check what our main screen will be. Is it an empty or an already initialized app?
            model.initialScreen()
                .environmentObject(model)
                .zcashEnvironment(ZcashEnvironment.default)
            
        }
    }
}



class ZcashPoSModel: ObservableObject {
    
    enum PoSError: Error {
        case failedToStart(error: Error)
        case unableToRetrieveCredentials
    }
    
    struct ZECRequest {
        var amount: Double
        var code: String
    }
    
    @Published var tabSelection: AppNavigation.Tab = .sell
    @Published var status = AppNavigation.AppStatus.empty
    @Published var navigation: AppNavigation.Screen? = nil
    @Published var currentPayment: ZECRequest? = nil
    
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
            NavigationView {
                ImportViewingKey()
            }
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
    }
    
    enum Tab {
        case sell
        case received
        case settings
    }
    
    enum Screen {
        case importViewingKey
        case home
        case receivedTransaction
        case settings
        case sell
        case request
        @ViewBuilder func buildScreen() -> some View {
            switch self {
            case .importViewingKey:
                ImportViewingKey()
            case .home:
                HomeScreen()
            case .receivedTransaction:
                ReceivedTransactions()
            case .settings:
                SettingsScreen()
            case .request:
                RequestZec()
            case .sell:
                SellScreen()
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
