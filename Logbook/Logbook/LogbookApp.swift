//
//  LogbookApp.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/01/2022.
//

import SwiftUI
import Firebase

@main
struct LogbookApp: App {
    
    init() {
        UITextView.appearance().backgroundColor = .clear
        UITextView.appearance().isScrollEnabled = false
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { reader in
                ZStack {
                    HomeView()
                }
                .frame(width: reader.size.width, height: reader.size.height)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
