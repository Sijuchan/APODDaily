//
//  APODRepository.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation


struct APODResult {
    let apod: APOD
    let isCached: Bool
}

final class APODRepository: APODRepositoryProtocol {
    
    
    private let service: APODServiceProtocol
    private let cache: APODDiskCacheProtocol
    
    init(service: APODServiceProtocol = APODService(), cache: APODDiskCacheProtocol = APODDiskCache()) {
        self.service = service
        self.cache = cache
    }
    
    
    func fetchAPOD(for date: Date?) async throws -> APODResult {
        do {
            let dto = try await service.fetchAPOD(for: date)
            let image = try await fetchImageIfNeeded(dto)
            
            try cache.save(dto: dto, image: image, key: dto.date)
            
            let apod = try APODMapper.map(dto: dto, imageData: image)
            
            debugPrint("apod.media --->> \(apod.media)")
            
            return APODResult(apod: apod, isCached: false)
            
        } catch {
            if let cached = try? cache.loadLatest() {
                let apod = try APODMapper.map(dto: cached.dto, imageData: cached.image)
                return APODResult(apod: apod, isCached: true)
            }
            throw error
        }
    }
    
    private func fetchImageIfNeeded(_ dto: APODDTO) async throws -> Data? {
        guard dto.mediaType == "image",
              let url = URL(string: dto.url) else { return nil }
        
        return try await URLSession.shared.data(from: url).0
    }
}


final class MockAPODRepository: APODRepositoryProtocol {
    func fetchAPOD(for date: Date?) async throws -> APODResult {
        return APODResult(
            apod: .preview,
            isCached: false
        )
    }
}
