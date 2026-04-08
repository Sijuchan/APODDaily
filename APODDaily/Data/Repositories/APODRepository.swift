//
//  APODRepository.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation

import Foundation

struct APODResult {
    let apod: APOD
    let isCached: Bool
}

final class APODRepository: APODRepositoryProtocol {
    

    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String ?? "DEMO_KEY"
    
    private let cache: APODDiskCacheProtocol = APODDiskCache()

    func fetchAPOD(for date: Date?) async throws -> APODResult {
        do {
            let dto = try await fetchRemote(date: date)
            
            let image = try await fetchImageIfNeeded(dto)

            try cache.save(dto: dto, image: image, key: dto.date)

            let apod = try APODMapper.map(dto: dto, imageData: image)
            return APODResult(apod: apod, isCached: false)

        } catch {
            if let cached = try? cache.loadLatest() {
                let apod = try APODMapper.map(dto: cached.dto, imageData: cached.image)
                return APODResult(apod: apod, isCached: true)
            }
            throw error
        }
    }

    private func fetchRemote(date: Date?) async throws -> APODDTO {
        

        
        guard var components = URLComponents(string: "https://api.nasa.gov/planetary/apod") else {
            
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
        
        print("components.url! --->> \(components.url!.absoluteString)")

        let (data, response) = try await URLSession.shared.data(from: components.url!)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw APODError.badResponse(http.statusCode)
        }

        return try JSONDecoder().decode(APODDTO.self, from: data)
    }

    private func fetchImageIfNeeded(_ dto: APODDTO) async throws -> Data? {
        guard dto.mediaType == "image",
              let url = URL(string: dto.url) else { return nil }

        return try await URLSession.shared.data(from: url).0
    }
}
