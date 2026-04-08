//
//  APODDailyTests.swift
//  APODDailyTests
//
//  Created by Siju Satheesachandran on 06/04/2026.
//

import XCTest
@testable import APODDaily

private func makeImageDTO(
    date: String = "2026-04-08",
    title: String = "Test Title",
    explanation: String = "Test explanation.",
    url: String = "https://example.com/image.jpg",
    hdurl: String? = "https://example.com/hd.jpg"
) -> APODDTO {
    APODDTO(
        date: date,
        title: title,
        explanation: explanation,
        url: url,
        hdurl: hdurl,
        mediaType: "image",
        thumbnailUrl: nil
    )
}

private func makeVideoDTO(
    date: String = "2026-04-08",
    url: String = "https://www.youtube.com/embed/abc123",
    thumbnailUrl: String? = "https://example.com/thumb.jpg"
) -> APODDTO {
    APODDTO(
        date: date,
        title: "Video Title",
        explanation: "A video APOD.",
        url: url,
        hdurl: nil,
        mediaType: "video",
        thumbnailUrl: thumbnailUrl
    )
}

private func makeAPOD(title: String = "Galaxy") -> APOD {
    APOD(
        title: title,
        explanation: "Far away.",
        date: Date(),
        media: .image(nil, URL(string: "https://example.com/img.jpg"))
    )
}



final class APODMapperTests: XCTestCase {

    func test_map_imageDTO_returnsImageMediaWithHDURL() throws {
        let dto = makeImageDTO()
        let imageData = Data([0xFF, 0xD8])

        let apod = try APODMapper.map(dto: dto, imageData: imageData)

        XCTAssertEqual(apod.title, "Test Title")
        XCTAssertEqual(apod.explanation, "Test explanation.")

        guard case .image(let data, let url) = apod.media else {
            return XCTFail("Expected .image media")
        }
        XCTAssertEqual(data, imageData)
        XCTAssertEqual(url?.absoluteString, "https://example.com/hd.jpg")
    }

    func test_map_videoDTO_returnsVideoMedia() throws {
        let dto = makeVideoDTO()

        let apod = try APODMapper.map(dto: dto, imageData: nil)

        guard case .video(let videoURL, let thumbnailURL) = apod.media else {
            return XCTFail("Expected .video media")
        }
        XCTAssertEqual(videoURL.absoluteString, "https://www.youtube.com/embed/abc123")
        XCTAssertEqual(thumbnailURL?.absoluteString, "https://example.com/thumb.jpg")
    }
}



final class APODDateFormatterTests: XCTestCase {

    func test_roundTrip_parseAndFormat_isIdentity() {
        let original = "2023-12-31"
        let date = APODDateFormatter.parse(original)
        let formatted = APODDateFormatter.format(date)

        XCTAssertEqual(formatted, original)
    }
}



private final class MockRepository: APODRepositoryProtocol {
    enum Behaviour {
        case success(APOD, isCached: Bool)
        case failure(Error)
    }

    var behaviour: Behaviour

    init(_ behaviour: Behaviour) {
        self.behaviour = behaviour
    }

    func fetchAPOD(for date: Date?) async throws -> APODResult {
        switch behaviour {
        case .success(let apod, let isCached):
            return APODResult(apod: apod, isCached: isCached)
        case .failure(let error):
            throw error
        }
    }
}

@MainActor
final class APODDailyViewModelTests: XCTestCase {

    func test_load_success_transitionsToContent() async {
        let expectedAPOD = makeAPOD(title: "Nebula")
        let vm = APODDailyViewModel(
            autoLoad: false,
            repository: MockRepository(.success(expectedAPOD, isCached: false))
        )

        vm.load(date: nil)
        await Task.yield()
        try? await Task.sleep(nanoseconds: 100_000_000)

        guard case .content(let apod, let isCached) = vm.state else {
            return XCTFail("Expected .content")
        }
        XCTAssertEqual(apod.title, "Nebula")
        XCTAssertFalse(isCached)
    }

    func test_load_failure_transitionsToError() async {
        let vm = APODDailyViewModel(
            autoLoad: false,
            repository: MockRepository(.failure(APODError.badResponse(503)))
        )

        vm.load(date: nil)
        await Task.yield()
        try? await Task.sleep(nanoseconds: 100_000_000)

        guard case .error(let message) = vm.state else {
            return XCTFail("Expected .error")
        }
        XCTAssertFalse(message.isEmpty)
    }
}



private final class MockCache: APODDiskCacheProtocol {
    var savedDTO: APODDTO?
    var savedImage: Data?

    func save(dto: APODDTO, image: Data?, key: String) throws {
        savedDTO = dto
        savedImage = image
    }

    func loadLatest() throws -> (dto: APODDTO, image: Data?) {
        guard let dto = savedDTO else { throw APODError.noCache }
        return (dto, savedImage)
    }
}

final class APODCacheFallbackTests: XCTestCase {

    func test_loadLatest_afterSave_returnsMatchingDTO() throws {
        let cache = MockCache()
        let dto = makeImageDTO()
        let imageData = Data([0x89, 0x50, 0x4E, 0x47])

        try cache.save(dto: dto, image: imageData, key: dto.date)
        let (loaded, loadedImage) = try cache.loadLatest()

        XCTAssertEqual(loaded.date, dto.date)
        XCTAssertEqual(loaded.title, dto.title)
        XCTAssertEqual(loaded.mediaType, dto.mediaType)
        XCTAssertEqual(loadedImage, imageData)
    }
}
