//
//  APODService.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 09/04/2026.
//

import Foundation


final class APODService: APODServiceProtocol {

    private let apiKey: String
    private let baseURL = "https://api.nasa.gov/planetary/apod"

    init(apiKey: String = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String ?? "DEMO_KEY") {
        self.apiKey = apiKey
    }

    func fetchAPOD(for date: Date?) async throws -> APODDTO {
        
        guard var components = URLComponents(string: baseURL) else {
            
            throw APODError.invalidURL
        }

        components.queryItems = [
            .init(name: "api_key", value: apiKey),
            .init(name: "thumbs", value: "true")
        ]

        if let date {
            components.queryItems?.append(
                .init(name: "date", value: APODDateFormatter.format(date))
            )
        }

        guard let url = components.url else {
            throw APODError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw APODError.badResponse(http.statusCode)
        }

        return try JSONDecoder().decode(APODDTO.self, from: data)
    }
}

