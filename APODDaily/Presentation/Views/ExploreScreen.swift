//
//  BrowseScreen.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import SwiftUI

struct ExploreScreen: View {
    @ObservedObject var viewModel: APODDailyViewModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                DatePicker(
                    "Select a date",
                    selection: $viewModel.selectedDate,
                    in: ...viewModel.maximumSelectableDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)

                Button {
                    viewModel.load(date: viewModel.selectedDate)
                } label: {
                    Label("Load", systemImage: "calendar.badge.clock")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.top)
            .background(.background)

            Divider()

            APODDailyScreen(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            viewModel.onBrowseAppear()
        }
        .onChange(of: viewModel.selectedDate) { _, newDate in
            viewModel.load(date: newDate)
        }
    }
}
