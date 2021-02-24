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

