//
//  AppCoordinator.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//


import SwiftUI

final class AppCoordinator {

    func start() -> some View {
        TabView {
            APODCoordinator(mode: .today).start()
                .tabItem { Label("Today", systemImage: "sparkles") }

            APODCoordinator(mode: .browse).start()
                .tabItem { Label("Explore", systemImage: "calendar") }
        }
    }
}

enum APODFlowMode {
    case today
    case browse
}
