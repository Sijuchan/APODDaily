//
//  APODDiskCache.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation

final class APODDiskCache: APODDiskCacheProtocol {

    private let baseDirectory: URL
    private let latestKeyFile: URL

    init() {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]

        baseDirectory = cacheDirectory.appendingPathComponent(
            "APODCache",
            isDirectory: true
        )

        latestKeyFile = baseDirectory.appendingPathComponent("latest.txt")

        do {
            try fileManager.createDirectory(
                at: baseDirectory,
                withIntermediateDirectories: true
            )
            debugPrint("---->> Cache directory created at:", baseDirectory.path)
        } catch {
            debugPrint("---->>  Failed to create cache directory:", error)
        }
    }

    func save(dto: APODDTO, image: Data?, key: String) throws {
        debugPrint("---->>   Saving cache for key:", key)

        let jsonURL = jsonURL(for: key)
        let imageURL = imageURL(for: key)

        // ---->>  Save DTO
        do {
            let data = try JSONEncoder().encode(dto)
            try data.write(to: jsonURL, options: .atomic)
            debugPrint("---->> DTO saved:", jsonURL.lastPathComponent)
        } catch {
            debugPrint("---->> Failed to save DTO:", error)
            throw error
        }

        // ---->>  Save image if present
        if let image {
            do {
                try image.write(to: imageURL, options: .atomic)
                debugPrint("--->> Image saved:", imageURL.lastPathComponent)
            } catch {
                debugPrint("--->>> Failed to save image:", error)
                throw error
            }
        } else {
            debugPrint("---->>> No image to cache for key:", key)
        }

        // ---->>> Save latest key reference
        if let keyData = key.data(using: .utf8) {
            try? keyData.write(to: latestKeyFile, options: .atomic)
        }
    }

    func loadLatest() throws -> (dto: APODDTO, image: Data?) {
        debugPrint("[--->>  Loading latest cached entry")

        let key: String
        do {
            key = try String(contentsOf: latestKeyFile, encoding: .utf8)
        } catch {
            debugPrint("--->> No latest key found")
            throw APODError.noCache
        }

        debugPrint("--->> Latest key:", key)

        let jsonURL = jsonURL(for: key)
        let imageURL = imageURL(for: key)

        // Load DTO
        let dto: APODDTO
        do {
            let data = try Data(contentsOf: jsonURL)
            dto = try JSONDecoder().decode(APODDTO.self, from: data)
        } catch {
            debugPrint("--->>Failed to load cached DTO:", error)
            throw error
        }

        //--------->>>>   Load image ==>> optional
        
        let image = try? Data(contentsOf: imageURL)

        if image == nil {
            debugPrint(" -->> No cached image found for key:", key)
        }

        return (dto, image)
    }


    private func jsonURL(for key: String) -> URL {
        baseDirectory.appendingPathComponent("\(key).json")
    }

    private func imageURL(for key: String) -> URL {
        baseDirectory.appendingPathComponent("\(key).bin")
    }
}

