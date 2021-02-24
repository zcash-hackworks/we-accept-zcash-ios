//
//  CombineSynchronizer.swift
//  wallet
//
//  Created by Francisco Gindre on 1/27/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine
import ZcashLightClientKit
class CombineSynchronizer {
    
    var initializer: Initializer {
        synchronizer.initializer
    }
    
    private var synchronizer: SDKSynchronizer
    
    var receivedTransactionBuffer: CurrentValueSubject<[DetailModel],Never>
    var status: CurrentValueSubject<Status,Never>
    var progress: CurrentValueSubject<Float,Never>
    var syncBlockHeight: CurrentValueSubject<BlockHeight,Never>
    var minedTransaction = PassthroughSubject<PendingTransactionEntity,Never>()
    var balance: CurrentValueSubject<Double,Never>
    var verifiedBalance: CurrentValueSubject<Double,Never>
    var cancellables = [AnyCancellable]()
    var errorPublisher = PassthroughSubject<Error, Never>()
    var receivedTransactions: Future<[ConfirmedTransactionEntity],Never> {
        Future<[ConfirmedTransactionEntity], Never>() {
            promise in
            DispatchQueue.global().async {
                [weak self] in
                guard let self = self else {
                    promise(.success([]))
                    return
                }
                promise(.success(self.synchronizer.receivedTransactions))
            }
        }
    }
    
    var sentTransactions: Future<[ConfirmedTransactionEntity], Never> {
        Future<[ConfirmedTransactionEntity], Never>() {
            promise in
            DispatchQueue.global().async {
                [weak self] in
                guard let self = self else {
                    promise(.success([]))
                    return
                }
                promise(.success(self.synchronizer.sentTransactions))
            }
        }
    }
    
    var pendingTransactions: Future<[PendingTransactionEntity], Never> {
        
        Future<[PendingTransactionEntity], Never>(){
            [weak self ] promise in
            
            guard let self = self else {
                promise(.success([]))
                return
            }
            
            DispatchQueue.global().async {
                promise(.success(self.synchronizer.pendingTransactions))
            }
        }
    }
    
    var latestHeight: Future<BlockHeight,Error> {
        Future<BlockHeight,Error>() {
            [weak self ] promise in
            
            guard let self = self else { return }
            self.synchronizer.latestHeight { (result) in
                switch result {
                case .success(let height):
                    promise(.success(height))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    func latestDownloadedHeight() throws -> BlockHeight {
        try self.synchronizer.latestDownloadedHeight()
    }
    
    init(initializer: Initializer) throws {
        self.receivedTransactionBuffer = CurrentValueSubject([DetailModel]())
        self.synchronizer = try SDKSynchronizer(initializer: initializer)
        self.status = CurrentValueSubject(.disconnected)
        self.progress = CurrentValueSubject(0)
        self.balance = CurrentValueSubject(0)
        self.verifiedBalance = CurrentValueSubject(0)
        self.syncBlockHeight = CurrentValueSubject(ZcashSDK.SAPLING_ACTIVATION_HEIGHT)
        
        // BUGFIX: transactions history empty when synchronizer fails to connect to server
        // fill with initial values
        self.updatePublishers()
        
        // Subscribe to SDKSynchronizer notifications
        
        NotificationCenter.default.publisher(for: .synchronizerSynced)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
                self.updatePublishers()
        }).store(in: &cancellables)
        

        NotificationCenter.default.publisher(for: .synchronizerStarted)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
            self?.status.send(.syncing)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerProgressUpdated)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (progressNotification) in
            guard let self = self else { return }
            guard let newProgress = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.progress] as? Float else { return }
            self.progress.send(newProgress)
            
            guard let blockHeight = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.blockHeight] as? BlockHeight else { return }
            self.syncBlockHeight.send(blockHeight)
        }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerMinedTransaction)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] minedNotification in
            guard let self = self else { return }
            guard let minedTx = minedNotification.userInfo?[SDKSynchronizer.NotificationKeys.minedTransaction] as? PendingTransactionEntity else { return }
            self.minedTransaction.send(minedTx)
        }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerFailed)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] (notification) in
            
            guard let self = self else { return }
            
            guard let error = notification.userInfo?[SDKSynchronizer.NotificationKeys.error] as? Error else {
                self.errorPublisher.send(
                
                    SynchronizerError.generalError(message: "An error ocurred, but we can't figure out what it is. Please check device logs for more details")
                )
                return
            }
                
            self.errorPublisher.send(error)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerStopped)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.status.send(.stopped)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.status.send(.disconnected)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerSyncing)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.status.send(.syncing)
            }
            .store(in: &cancellables)
    }
    
    func start(retry: Bool = false) throws {
        
        do {
            if retry {
                stop()
            }
            try synchronizer.start(retry: retry)
        } catch {
//            logger.error("error starting \(error)")
            throw error
        }
    }
    
    func stop() {
        synchronizer.stop()
    }
    
    func cancel(pendingTransaction: PendingTransactionEntity) -> Bool {
        synchronizer.cancelSpend(transaction: pendingTransaction)
    }
    
    func updatePublishers() {
        self.balance.send(initializer.getBalance().asHumanReadableZecBalance())
        self.verifiedBalance.send(initializer.getVerifiedBalance().asHumanReadableZecBalance())
        self.status.send(.synced)
        self.receivedTransactions.sink(receiveCompletion: { _ in
            }) { [weak self] (details) in
                guard !details.isEmpty else { return }
            self?.receivedTransactionBuffer.send(details.map({ DetailModel(confirmedTransaction: $0) }))
        }
        .store(in: &self.cancellables)
    }
    
    deinit {
        synchronizer.stop()
        for c in cancellables {
            c.cancel()
        }
    }
    
    func send(with spendingKey: String, zatoshi: Int64, to recipientAddress: String, memo: String?,from account: Int) -> Future<PendingTransactionEntity,Error>  {
        Future<PendingTransactionEntity, Error>() {
            promise in
            self.synchronizer.sendToAddress(spendingKey: spendingKey, zatoshi: zatoshi, toAddress: recipientAddress, memo: memo, from: account) { (result) in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success(let pendingTx):
                    promise(.success(pendingTx))
                }
            }
        }
    }
}
