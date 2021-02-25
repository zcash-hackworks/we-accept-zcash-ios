//
//  DetailModel.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/22/21.
//

import Foundation
import SwiftUI

struct DetailModel: Identifiable {
    
    enum Status {
        case paid(success: Bool)
        case received
    }
    var id: String
    var zAddress: String?
    var date: Date
    var zecAmount: Double
    var status: Status
    var shielded: Bool = true
    var memo: String? = nil
    var minedHeight: Int = -1
    var expirationHeight: Int = -1
    var title: String {

        switch status {
        case .paid(let success):
            return success ? "You paid \(zAddress?.shortZaddress ?? "Unknown")" : "Unsent Transaction"
        case .received:
            return "\(zAddress?.shortZaddress ?? "Unknown") paid you"
        }
    }
    
    var subtitle: String
    
}

extension DetailModel: Equatable {
    static func == (lhs: DetailModel, rhs: DetailModel) -> Bool {
        lhs.id == rhs.id
    }
}
extension DetailModel: Hashable {}
extension DetailModel.Status: Hashable {}

import ZcashLightClientKit
extension Date {
    var transactionDetail: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy h:mm a"
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
extension DetailModel {
    init(confirmedTransaction: ConfirmedTransactionEntity, sent: Bool = false) {
        self.date = Date(timeIntervalSince1970: confirmedTransaction.blockTimeInSeconds)
        self.id = confirmedTransaction.transactionEntity.transactionId.toHexStringTxId()
        self.shielded = confirmedTransaction.toAddress?.isValidShieldedAddress ?? true
        self.status = sent ? .paid(success: confirmedTransaction.minedHeight > 0) : .received
        self.subtitle = sent ? "Sent" + " \(self.date.transactionDetail)" : "Received" + " \(self.date.transactionDetail)"
        self.zAddress = confirmedTransaction.toAddress
        self.zecAmount = (sent ? -Int64(confirmedTransaction.value) : Int64(confirmedTransaction.value)).asHumanReadableZecBalance()
        if let memo = confirmedTransaction.memo {
            self.memo = memo.asZcashTransactionMemo()
        }
        self.minedHeight = confirmedTransaction.minedHeight
    }
    init(pendingTransaction: PendingTransactionEntity, latestBlockHeight: BlockHeight? = nil) {
        let submitSuccess = pendingTransaction.isSubmitSuccess
        let isPending = pendingTransaction.isPending(currentHeight: latestBlockHeight ?? -1)
        
        self.date = Date(timeIntervalSince1970: pendingTransaction.createTime)
        self.id = pendingTransaction.rawTransactionId?.toHexStringTxId() ?? String(pendingTransaction.createTime)
        self.shielded = pendingTransaction.toAddress.isValidShieldedAddress
        self.status = .paid(success: submitSuccess)
        self.expirationHeight = pendingTransaction.expiryHeight
        self.subtitle = DetailModel.subtitle(isPending: isPending,
                                             isSubmitSuccess: submitSuccess,
                                             minedHeight: pendingTransaction.minedHeight,
                                             date: self.date.transactionDetail,
                                             latestBlockHeight: latestBlockHeight)
        self.zAddress = pendingTransaction.toAddress
        self.zecAmount = -Int64(pendingTransaction.value).asHumanReadableZecBalance()
        if let memo = pendingTransaction.memo {
            self.memo = memo.asZcashTransactionMemo()
        }
        self.minedHeight = pendingTransaction.minedHeight
    }
}

extension DetailModel {
    var isSubmitSuccess: Bool {
        switch status {
        case .paid(let s):
            return s
        default:
            return false
        }
    }
    
    static func subtitle(isPending: Bool, isSubmitSuccess: Bool, minedHeight: BlockHeight, date: String, latestBlockHeight: BlockHeight?) -> String {
        
        guard isPending else {
            return "Sent \(date)"
        }
        
        guard minedHeight > 0, let latestHeight = latestBlockHeight, latestHeight > 0 else {
            return "Pending confirmation"
        }
        
        return "\(abs(latestHeight - minedHeight)) of 10 Confirmations"
    }
}
