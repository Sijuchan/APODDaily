//
//  APODViewModel.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//


import Foundation
import Combine

@MainActor
final class APODDailyViewModel: ObservableObject {
    
    enum State: Equatable {
        case idle
        case loading
        case content(APOD, isCached: Bool)
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published var selectedDate: Date

    let maximumSelectableDate: Date

    private let autoLoad: Bool
    private let repository: APODRepositoryProtocol
    
    private var hasLoaded = false
    private var loadTask: Task<Void, Never>?

    init(autoLoad: Bool,repository: APODRepositoryProtocol,maximumSelectableDate: Date = .now,initialSelectedDate: Date = .now) {
        self.autoLoad = autoLoad
        self.repository = repository
        self.maximumSelectableDate = maximumSelectableDate
        self.selectedDate = min(initialSelectedDate, maximumSelectableDate)

        debugPrint("-->>ViewModel init - autoLoad: \(autoLoad), selectedDate: \(self.selectedDate)")
    }

    deinit {
        debugPrint("--->>ViewModel deinit - cancelling any ongoing task")
        loadTask?.cancel()
    }



    func onAppear() {
        debugPrint("-->> onAppear called")

        guard autoLoad, !hasLoaded else {
            debugPrint("-->>Skipping auto load")
            return
        }

        hasLoaded = true
        debugPrint("-- >>Triggering initial load for Today")
        load(date: Date.now)
    }

    func onBrowseAppear() {
        debugPrint("--->>Browse screen appeared")

        guard !hasLoaded else {
            debugPrint("Already loaded once")
            return
        }

        hasLoaded = true
        debugPrint("-- >>Loading for selected date: \(selectedDate)")
        load(date: selectedDate)
    }


    func load(date: Date?) {
        debugPrint("Starting load")

        loadTask?.cancel()
        state = .loading
       
        let requestedDate: Date?
        if let date {
            requestedDate = min(date, maximumSelectableDate)
        } else {
            requestedDate = nil
        }

        if let requestedDate {
            debugPrint("Fetching APOD for date: \(requestedDate)")
        } else {
            debugPrint("Fetching today APOD")
        }

        loadTask = Task { [repository] in
            do {
                let result = try await repository.fetchAPOD(for: requestedDate)

                guard !Task.isCancelled else {
                    debugPrint("Task cancelled before completion")
                    return
                }

                debugPrint("-->>Data loaded successfully (cached: \(result.isCached))")
                state = .content(result.apod, isCached: result.isCached)

            } catch is CancellationError {
                debugPrint("Request cancelled--->>")
                return

            } catch {
                debugPrint("Failed to load APOD: \(error.localizedDescription)")
                state = .error("Failed to load APOD.")
            }
        }
    }
}
