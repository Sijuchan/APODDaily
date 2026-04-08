//
//  APODRepositoryProtocol.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation

protocol APODRepositoryProtocol {
    func fetchAPOD(for date: Date?) async throws -> APODResult
}
