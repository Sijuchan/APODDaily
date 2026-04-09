//
//  APODServiceProtocol.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 09/04/2026.
//

import Foundation


protocol APODServiceProtocol {
    func fetchAPOD(for date: Date?) async throws -> APODDTO
}
