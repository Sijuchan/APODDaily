//
//  APODError.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation


enum APODError: LocalizedError, Equatable {
    case invalidURL
    case badResponse(Int)
    case decodingFailed
    case noCache

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request."
        case .badResponse(let code):
            return "Server error (\(code))."
        case .decodingFailed:
            return "Failed to process response."
        case .noCache:
            return "No cached data available."
        }
    }
}
