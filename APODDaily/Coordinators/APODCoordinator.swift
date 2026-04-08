//
//  APODCoordinator.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//


import Foundation
import SwiftUI

class APODCoordinator {
    
    private let mode: APODFlowMode

    init(mode: APODFlowMode) {
        self.mode = mode
    }

    @ViewBuilder
    func start() -> some View {
        let repository = APODRepository()
        let viewModel = APODDailyViewModel(
            autoLoad: mode == .today,
            repository: repository
        )

        NavigationStack {
            switch mode {
            case .today:
                APODDailyScreen(viewModel: viewModel)
            case .browse:
                ExploreScreen(viewModel: viewModel)
            }
        }
    }
}
