//
//  APODDailyApp.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 06/04/2026.
//

import SwiftUI

@main
struct APODDailyApp: App {
    private let coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
