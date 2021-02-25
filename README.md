# we-accept-zcash-ios
A Proof-of-Concept on how to build a Small iOS App that lets you accept Zcash as payment

This project is a part of the Code With Me Session for Hello Decentralization 2021.

## Tag: `step-0`

Create an Xcode project for the app `accept-zcash-pos` using SwiftUI


## Tag: `step-1-integrate-sdk`

In this step we are going to integrate the `ZcashLightClientKit` SDK into the project using Cocoapods. 

Follow installation instructions in ZcashLightClientKit home page: https://github.com/zcash/ZcashLightClientKit

Once you have the default project building successfully.

Let's try to see if this all works

On ContentView.swift, import `ZcashLightClientKit` and add a text saying hello to the corresponding Zcash network.

````

 import ZcashLightClientKit
 struct ContentView: View {
     var body: some View {
        
        Text("Hello, Zcash \(ZcashSDK.isMainnet ? "MainNet" : "TestNet")")
             .padding()
     }
 }
````

## Tag: `step-2-the-look`
We are going to import quite a few perks from the ECC Wallet. 
The "UI Elements" folder contains several UI components we use on our app. 
 

## Tag: `step-3-import-viewing-key-scaffold`
Let's make a scaffold for our first task: Importing a viewing key

We added he "Utils" folder has some tricks we learned along the way to make swift ui more usable. Like keyboard avoidance support.

We renamed the ContentView to ImportViewingKey and added the text field and a nice Zcash Logo!


## Tag: `step-4-import-viewing-key-for-real-and-sync-it`

We have the import viewing key screen laid out. Let's put it to work! That's a little bit trickier though! 

First we need to create a ZcashEnvironment were all things ZcashSDK will live

```
class ZcashEnvironment {
    static let `default`: ZcashEnvironment = try! ZcashEnvironment()
    
    // you can spin up your own node and lightwalletd, check https://zcash.readthedocs.io/en/latest/rtd_pages/zcashd.html
    let endpoint = LightWalletEndpoint(address: ZcashSDK.isMainnet ? "localhost" : "localhost", port: 9067, secure: true)

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
}
```

Let's wire up the ZcashEnvironment

````
struct ImportViewingKey: View {

    @EnvironmentObject var model: ZcashPoSModel
    @Environment(\.zcashEnvironment) var zcash: ZcashEnvironment // this is where your zcash stuff lives
````

Then we need to turn that dummy button into something meaningful.

````
// let's make a navigation link that goes to a new screen called HomeScreen. 
NavigationLink(destination: AppNavigation.Screen.home.buildScreen(), tag: AppNavigation.Screen.home , selection: $model.navigation
    ) {
        Button(action: {
            do {
                let bday = validStringToBirthday(birthday)
                try zcash.initialize(viewingKey: ivk, birthday: bday)
                // now that we initialized the zcash environment let's save the viewing key and birthday
                model.birthday = bday
                model.viewingKey = ivk
                
                // let's navigate to the next screen
                model.navigation = AppNavigation.Screen.home
            } catch {
                
                // if something does wrong, let's do nothing and show an Alert!
                self.alertType = .errorAlert(error)
            }
        }) {
            Text("Import Viewing Key")
                .foregroundColor(.black)
                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: .zButtonGradient)))
        }

````

In our `HomeScreen` view we are going to show little to nothing for now.

the important thing is that we are going to inject our PoS model and the Zcash environment. 

For now we are going to say that out app is either going to be ready, syncing or offline

````
struct HomeScreen: View {
    enum Status {
        case ready
        case syncing
        case offline
    }
    
    @EnvironmentObject var model: ZcashPoSModel
    @Environment(\.zcashEnvironment) var zcash: ZcashEnvironment
````
```
VStack(alignment: .center, spacing: 20) {
    ZcashLogo()
    switch status {
    case .offline:
         Text("Offline").foregroundColor(.white)
    case .ready:
         Text("Ready! Yay!").foregroundColor(.white)
    case .syncing:
         Text("Syncing \(progress)% Block: \(height)").foregroundColor(.white)
    }
    
    Button(action: {
        zcash.synchronizer.stop()
        model.nuke()
    }) {
        Text("Stop And Nuke")
            .foregroundColor(.red)
            .font(.title3)
    }
}

```


On our main app we will have to make room for the Home screen so we will have to change the way we initialize it. 

````
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
````
We will consider our app to be empty when it has no viewing keys loaded

```
var appStatus: AppNavigation.AppStatus {
    guard let vk = self.viewingKey, ((try? DerivationTool.default.isValidExtendedViewingKey(vk)) != nil) else {
        return .empty
    }
    return .initialized
}
```


On the other hand it's possible that we don't want to use this viewing key on this device anymore, so we added a **NUKE** function to clear it out. 

```
func nuke() {
    self.birthday = nil
    self.viewingKey = nil
}
```


If you diff this commit you will see that there are a lot of changes and other files. Think of it as a cooking show with some pre-arrangements made for the sake of brevity. We encourage you to look at those changes! 


## Tag: `step-5-split-to-tab-view`

We are going to change the HomeScreen into a TabView 

so we will move its contents to the `SellView`, other tab is going to be the `ReceivedTransactions` and  a Settings tab where we will be moving the nuking button for now

````
struct HomeScreen: View {
 
    @Environment(\.zcashEnvironment) var zcash: ZcashEnvironment
    @EnvironmentObject var model: ZcashPoSModel
    @State var alertType: AlertType? = nil

    var body: some View {

            TabView {
                SellScreen()
                    .tabItem {
                        Label("Sell", systemImage: "shield")
                    }
                ReceivedTransactions()
                    .tabItem {
                        Label("History", systemImage: "square.and.pencil")
                    }
                
                SettingsScreen()
                    .tabItem {
                        Label("Settings", systemImage: "list.dash")
                    }
                

            }
        .navigationBarHidden(false)
        .onAppear() {
            _zECCWalletNavigationBarLookTweaks()
            do {
                guard let ivk = model.viewingKey, let bday = model.birthday else {
                    throw ZcashPoSModel.PoSError.unableToRetrieveCredentials
                }
                try self.zcash.synchronizer.initializer.initialize(viewingKeys: [ivk], walletBirthday: bday)
                try self.zcash.synchronizer.start()
            } catch {
                self.alertType = AlertType.errorAlert(error)
            }
        }
        .alert(item: $alertType) { (type) -> Alert in
            type.buildAlert()
        }
    }
}
````

## Tag: `step-6-Sell-Screen`

We are going to create a sell screen where we will generate a QR code with our address and some instructions for our customer to send us the requested ZEC along some memo. 

We are going to move some other elements to the SettingsView, and Create a form in the `SellScreen` view where we will request some amount and enter an order code, that will be shown on the request screen so that the user types that code in the transaction memo.

````
/// SellScreen.swift
var body: some View {
    NavigationView {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 20) {
                ZcashLogo(width: 50)
                    
                Spacer()
                ZcashTextField(title: "Zec Amount To Request",
                               subtitleView: amountSubtitle,
                               contentType: nil,
                               keyboardType: .numberPad,
                               binding: $numberString,
                               action: nil,
                               accessoryIcon: nil,
                               onEditingChanged: { _ in }, onCommit: {})
                
                ZcashTextField(title: "Order Code",
                               subtitleView: codeSubtitle,
                               binding: $orderCode) { _ in } onCommit: {}
````


We are going to create the Request Screen. It will allow the user to see the information needed to create the transaction

````
struct RequestZec: View {
    @EnvironmentObject var model: ZcashPoSModel
    @State var zAddress: String? = nil
    @State var alertType: AlertType? = nil
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 40){
                Text("To This address:")
                    .foregroundColor(.white)
                Text(zAddress ?? "Error Deriving Address")
                    .foregroundColor(.white)
                
                Text("$\(model.request.amount.toZecAmount())")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.white)
                .font(
                    .custom("Zboto", size: 72)
                )
                
                Text("Append Memo With this Code")
                    .foregroundColor(.white)
                Text(model.request.code)
                    .foregroundColor(.white)
                    .font(.title)
            }
        }.navigationTitle("Pay with ZEC")
````

The interesting part is this: We can derive a Z-Address from viewing key! 
We can do this and many more things with the `DerivationTool` class of the Zcash SDK.

````
.onAppear() {
    do {
        guard let ivk = model.viewingKey else {
            self.alertType = .errorAlert(ZcashPoSModel.PoSError.unableToRetrieveCredentials)
            return
        }
        self.zAddress = try DerivationTool.default.deriveShieldedAddress(viewingKey: ivk)
    } catch {
        self.alertType = .errorAlert(error)
    }
}
````

Unfortunately this screen is really helpful. we need to get some QR code so that the user can scan the address! We will see that on the next step


## Tag: `step-7-request-zec-qr-code`

On this step we are just going to request zec in a decent way that's useful to our customers.  For that we will have to create a QR Code Image and display in on screen. Fortunately our ECC Wallet App already does this and we are going to borrow some code from it. 

The first thing we need is a QR Code generator. iOS already does that pretty well, but the API is somewhat rough. So we created this helper class called  `QRCodeGenerator`

We are going to add this snippet to the `RequestZec` screen struct
````
// This Generates the QR Image
var qrImage: Image {
    if let zAddr = self.zAddress, let img = QRCodeGenerator.generate(from: zAddr) {
        return Image(img, scale: 1, label: Text(String(format:NSLocalizedString("QR Code for %@", comment: ""),"\(zAddr)") ))
    } else {
        return Image("zebra_profile")
    }
}
````

and also this one to the body of the view  so that the qr code is show. or a nice zebra placeholder otherwise

````
QRCodeContainer(qrImage: qrImage,
                badge: Image("QR-zcashlogo"))
    .frame(width: qrSize, height: qrSize, alignment: .center)
    .layoutPriority(1)
````
We borrowed some nice assets from the wallet too! A cool zebra, and a nice shield for our QR code.

And that's it! Customers will be able to scan our Zcash Sapling Address! 

Our next step will be receiving the transactions.

## Tag: `step-8-received-transactions`

We synced our Viewing Key and created a Request Zec Screen. Now we need to know whether we received the payment or not.

We follow our experts' recommendation of waiting 10 confirmations for those funds to be spendable, but we will be able to see the incoming payment as soon as it is mined.

So let's give our `ReceivedTransactions` screen some love.

first let's add the ZcashEnvironment and the App's model, and also two @State variables, one for the selection (yes, we are going to see the Tx details too!) and the other ones for the transactions that were decrypted with our viewing key.

````
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
````

We are going to show an empty state when we don't see any transactions and an (ugly) list when we do with this view builder

````
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
    
````

I once nuked my app by mistake so we are also going to fix that. On this commit you will see several bug fixes! If you find more, or have improvement ideas, please send a pull request!

Alright Folks! This is it for the time being! 

Android devs, I dare you to create the same app for your beloved green robot using the zcash-android-wallet-sdk!

