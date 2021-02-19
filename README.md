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






