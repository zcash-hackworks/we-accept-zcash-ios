//
//  ReceivedTransactions.swift
//  accept-zcash-poc
//
//  Created by Francisco Gindre on 2/24/21.
//

import SwiftUI

struct ReceivedTransactions: View {
    @EnvironmentObject var model: ZcashPoSModel
    @Environment(\.zcashEnvironment) var zcash: ZcashEnvironment
    @State var selection: DetailModel? = nil
    @State var transactions: [DetailModel] = []
    
    var body: some View {
        NavigationView {
            buildBody(transactions: transactions)
                .navigationBarTitle("Received Transactions", displayMode: .inline)
                .navigationBarHidden(false)
                .onReceive(zcash.synchronizer.receivedTransactionBuffer) { (r) in
                    self.transactions = r
                }
        }.onAppear() {
            let clearView = UIView()
            clearView.backgroundColor = UIColor.clear
            UITableViewCell.appearance().selectedBackgroundView = clearView
            UITableView.appearance().backgroundColor = UIColor.clear
        }
        
    }
    
    @ViewBuilder func buildBody(transactions: [DetailModel]) -> some View {
        if transactions.isEmpty {
            ZStack {
                ZcashBackground()
                Text("No transactions yet")
                    .foregroundColor(.white)
            }
        } else {
            ZStack {
                ZcashBackground()
                List(transactions) { (row)  in
                    ZStack {
                        ZcashBackground()
                        NavigationLink(destination: TransactionDetails(model: row,isCopyAlertShown: false), tag: row, selection: $selection) {
                           EmptyView()
                            
                        }
                        HStack {
                            VStack {
                                Text(row.memo ?? "No Memo")
                                    .foregroundColor(.white)
                                Text(row.subtitle)
                                    .foregroundColor(.white)
                            }
                            Text("$\(row.zecAmount.toZecAmount())")
                                .foregroundColor(.zPositiveZecAmount)
                        }
                        .frame(height: 64)
                        
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(0)
                        
                    }
                    
                }
                .listStyle(PlainListStyle())
                .listRowBackground(ZcashBackground())
            }
        }
    }
}

struct ReceivedTransactions_Previews: PreviewProvider {
    static var previews: some View {
        ReceivedTransactions()
    }
}
