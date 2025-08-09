//
//  VintageRockRadioApp.swift
//  VintageRockRadio
//
//  Created by graffiti75 on 08/08/25.
//

import SwiftUI

@main
struct VintageRockRadioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            VideoPlayerView()
        }
    }
}
