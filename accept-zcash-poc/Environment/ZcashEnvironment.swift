//
//  ZcashEnvironment.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/22/21.
//

import Foundation
import ZcashLightClientKit
import SwiftUI
class ZcashEnvironment {
    static let `default`: ZcashEnvironment = try! ZcashEnvironment()
    
    // you can spin up your own node and lightwalletd, check https://zcash.readthedocs.io/en/latest/rtd_pages/zcashd.html
    let endpoint = LightWalletEndpoint(address: ZcashSDK.isMainnet ? "mainnet.lightwalletd.com" : "testnet.lightwalletd.com", port: 9067, secure: true)

    var synchronizer: CombineSynchronizer
    
    private init() throws {
        let initializer = Initializer(
            cacheDbURL: try Self.cacheDbURL(),
            dataDbURL: try Self.dataDbURL(),
            pendingDbURL: try Self.pendingDbURL(),
            endpoint: endpoint,
            spendParamsURL: try Self.spendParamsURL(),
            outputParamsURL: try Self.outputParamsURL(),
            loggerProxy: logger)
        
        // this is where the magic happens
        self.synchronizer = try CombineSynchronizer(initializer: initializer)
    }
    
    /**
     Initializes the synchornizer with the given viewing key and birthday
     */
    func initialize(viewingKey: String, birthday: BlockHeight) throws {
        try self.synchronizer.initializer.initialize(viewingKeys: [viewingKey], walletBirthday: birthday)
    }
    
    func nuke() throws {
        do {
            try FileManager.default.removeItem(at: try Self.dataDbURL())
        } catch {
            logger.error("could not nuke wallet: \(error)")
        }
        do {
            try FileManager.default.removeItem(at: try Self.cacheDbURL())
        } catch {
            logger.error("could not nuke wallet: \(error)")
        }
        do {
            try FileManager.default.removeItem(at: try Self.pendingDbURL())
        } catch {
            logger.error("could not nuke wallet: \(error)")
        }
    }
}

fileprivate struct ZcashEnvironmentKey: EnvironmentKey {
    static let defaultValue: ZcashEnvironment = ZcashEnvironment.default
}

extension EnvironmentValues {
    var zcashEnvironment: ZcashEnvironment  {
        get {
            self[ZcashEnvironmentKey.self]
        }
        set {
            self[ZcashEnvironmentKey.self] = newValue
        }
    }
}

extension View {
    func zcashEnvironment(_ env: ZcashEnvironment) -> some View {
        environment(\.zcashEnvironment, env)
    }
}
 
extension ZcashEnvironment {
    
    static func documentsDirectory() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    static func cacheDbURL() throws -> URL {
        try documentsDirectory().appendingPathComponent(ZcashSDK.DEFAULT_DB_NAME_PREFIX+ZcashSDK.DEFAULT_CACHES_DB_NAME, isDirectory: false)
    }

    static func dataDbURL() throws -> URL {
        try documentsDirectory().appendingPathComponent(ZcashSDK.DEFAULT_DB_NAME_PREFIX+ZcashSDK.DEFAULT_DATA_DB_NAME, isDirectory: false)
    }

    static func pendingDbURL() throws -> URL {
        try documentsDirectory().appendingPathComponent(ZcashSDK.DEFAULT_DB_NAME_PREFIX+ZcashSDK.DEFAULT_PENDING_DB_NAME)
    }

    static func spendParamsURL() throws -> URL {
        Bundle.main.url(forResource: "sapling-spend", withExtension: ".params")!
    }

    static func outputParamsURL() throws -> URL {
        Bundle.main.url(forResource: "sapling-output", withExtension: ".params")!
    }
}
