//
//  TransactionDetail.swift
//  wallet
//
//  Created by Francisco Gindre on 4/14/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI

struct TransactionDetails: View {
    
    var model: DetailModel
    @State var isCopyAlertShown: Bool = false
    var status: String {
        
        switch model.status {
        case .paid(let success):
           return success ? "Outbound" : "Unsent"
        case .received:
            return "Inbound"
            }
    }
    
    func copyToClipBoard(_ content: String) {
        UIPasteboard.general.string = content
        logger.debug("content copied to clipboard")
        self.isCopyAlertShown = true
    }
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack {
               
                ScrollView([.vertical], showsIndicators: false) {
                    Text("$\(model.zecAmount.toZecAmount())")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.white)
                    .font(
                        .custom("Zboto", size: 72)
                    )

                    Text(status).foregroundColor(.white)
                        .font(.largeTitle)
                    Spacer()
                    VStack(alignment: .center, spacing: 10) {
                        if  model.minedHeight > 0 {
                            DetailCell(title: "Mined Height", description: "\(model.minedHeight)", action: nil)
                        }
                        DetailCell(title: "Tx Id:" , description: model.id, action: self.copyToClipBoard)
                        DetailCell(title: "Date:", description: model.date.description)
                        DetailCell(title: "Shielded:", description: model.shielded ? "🛡" : "❌")
                        DetailCell(title: "Memo:", description: model.memo ?? "No memo" , action: self.copyToClipBoard)
                        DetailCell(title: "Address:", description: model.zAddress ?? "", action: self.copyToClipBoard).opacity( model.zAddress != nil ? 1.0 : 0)
                        
                    }
                    Spacer()
                }.padding(.horizontal, 40)
            }
            
        }.alert(isPresented: self.$isCopyAlertShown) {
            Alert(title: Text(""),
                  message: Text("feedback_addresscopied"),
                  dismissButton: .default(Text("button_close"))
            )
        }
        .navigationBarTitle(Text("Transaction Detail"), displayMode: .inline)
        .navigationBarBackButtonHidden(false)

    }
}

struct DetailCell: View {
    var title: String
    var description: String
    var action: ((String) -> Void)?
    var body: some View {
        VStack {
            Text(title).foregroundColor(.zYellow)
                .font(.title)
            Text(description)
                .foregroundColor(.white)
        }
        .onTapGesture {
            self.action?(self.description)
        }
    }
}

