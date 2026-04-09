//
//  APODDailyTests.swift
//  APODDailyTests
//
//  Created by Siju Satheesachandran on 06/04/2026.
//

import XCTest
@testable import APODDaily


 
final class MockAPODRepository: APODRepositoryProtocol {
    var result: Result<APODResult, Error> = .failure(APODError.noCache)
    var fetchCallCount = 0
    var lastDateRequested: Date?
 
    func fetchAPOD(for date: Date?) async throws -> APODResult {
        fetchCallCount += 1
        lastDateRequested = date
        return try result.get()
    }
}
 

 
extension APODDTO {
    static let imageFixture = APODDTO(
        date: "2021-04-01",
        title: "Pillars of Creation",
        explanation: "Towering pillars of gas and dust.",
        url: "https://apod.nasa.gov/apod/image/2104/PillarsOfCreation.jpg",
        hdurl: "https://apod.nasa.gov/apod/image/2104/PillarsOfCreation_hd.jpg",
        mediaType: "image",
        thumbnailUrl: nil
    )
 
    static let videoFixture = APODDTO(
        date: "2021-10-11",
        title: "Halloween and the Sunflower Galaxy",
        explanation: "A spooky video APOD.",
        url: "https://www.youtube.com/embed/abc123",
        hdurl: nil,
        mediaType: "video",
        thumbnailUrl: "https://img.youtube.com/vi/abc123/0.jpg"
    )
}
 
extension APOD {
    static let imageFixture = APOD(
        title: "Pillars of Creation",
        explanation: "Towering pillars of gas and dust.",
        date: APODDateFormatter.parse("2021-04-01"),
        media: .image(nil, URL(string: "https://apod.nasa.gov/apod/image/2104/PillarsOfCreation_hd.jpg"))
    )
 
    static let videoFixture = APOD(
        title: "Halloween and the Sunflower Galaxy",
        explanation: "A spooky video APOD.",
        date: APODDateFormatter.parse("2021-10-11"),
        media: .video(
            URL(string: "https://www.youtube.com/embed/abc123")!,
            thumbnailURL: URL(string: "https://img.youtube.com/vi/abc123/0.jpg")
        )
    )
}
 

 
final class APODDateFormatterTests: XCTestCase {
 
    func testFormatAndParseRoundtrip() {
        let date = APODDateFormatter.parse("2021-04-01")
        XCTAssertEqual(APODDateFormatter.format(date), "2021-04-01")
    }
 
    func testParseReturnsCorrectDateComponents() {
        let date = APODDateFormatter.parse("2021-04-01")
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        XCTAssertEqual(cal.component(.year, from: date), 2021)
        XCTAssertEqual(cal.component(.month, from: date), 4)
        XCTAssertEqual(cal.component(.day, from: date), 1)
    }
}
 

 
final class APODMapperTests: XCTestCase {
 
    func testMapsImageDTOCorrectly() throws {
        let apod = try APODMapper.map(dto: .imageFixture, imageData: nil)
        XCTAssertEqual(apod.title, "Pillars of Creation")
        XCTAssertEqual(APODDateFormatter.format(apod.date), "2021-04-01")
        if case .image(let data, let url) = apod.media {
            XCTAssertNil(data)
            XCTAssertEqual(url?.absoluteString, "https://apod.nasa.gov/apod/image/2104/PillarsOfCreation_hd.jpg")
        } else {
            XCTFail("Expected image media")
        }
    }
 
    func testMapsVideoDTOCorrectly() throws {
        let apod = try APODMapper.map(dto: .videoFixture, imageData: nil)
        if case .video(let url, let thumb) = apod.media {
            XCTAssertEqual(url.absoluteString, "https://www.youtube.com/embed/abc123")
            XCTAssertEqual(thumb?.absoluteString, "https://img.youtube.com/vi/abc123/0.jpg")
        } else {
            XCTFail("Expected video media")
        }
    }
 
    func testFallsBackToUrlWhenNoHdurl() throws {
        let dto = APODDTO(
            date: "2021-04-01", title: "Test", explanation: "Test",
            url: "https://example.com/image.jpg", hdurl: nil,
            mediaType: "image", thumbnailUrl: nil
        )
        let apod = try APODMapper.map(dto: dto, imageData: nil)
        if case .image(_, let url) = apod.media {
            XCTAssertEqual(url?.absoluteString, "https://example.com/image.jpg")
        } else {
            XCTFail("Expected image media")
        }
    }
}
 

 
final class APODDiskCacheTests: XCTestCase {
 
    private var cache: APODDiskCache!
 
    override func setUp() {
        super.setUp()
        cache = APODDiskCache()
    }
 
    func testSaveAndLoadRoundtripsDTO() throws {
        try cache.save(dto: .imageFixture, image: nil, key: "cache-test-01")
        let loaded = try cache.loadLatest()
        XCTAssertEqual(loaded.dto.title, APODDTO.imageFixture.title)
        XCTAssertEqual(loaded.dto.date, APODDTO.imageFixture.date)
    }
 
    func testSaveAndLoadRoundtripsImageData() throws {
        let imageData = Data([0xFF, 0xD8, 0xFF])
        try cache.save(dto: .imageFixture, image: imageData, key: "cache-test-02")
        let loaded = try cache.loadLatest()
        XCTAssertEqual(loaded.image, imageData)
    }
 
    func testLoadLatestReturnsLastWrittenEntry() throws {
        try cache.save(dto: .imageFixture, image: nil, key: "cache-test-first")
        let second = APODDTO(
            date: "2021-04-02", title: "Second APOD", explanation: "Another day.",
            url: "https://example.com/second.jpg", hdurl: nil,
            mediaType: "image", thumbnailUrl: nil
        )
        try cache.save(dto: second, image: nil, key: "cache-test-second")
        let loaded = try cache.loadLatest()
        XCTAssertEqual(loaded.dto.title, "Second APOD")
    }
}
 

 
@MainActor
final class APODDailyViewModelTests: XCTestCase {
 
    private var mockRepo: MockAPODRepository!
 
    override func setUp() {
        super.setUp()
        mockRepo = MockAPODRepository()
    }
 
    func testInitialStateIsIdleWhenAutoLoadDisabled() {
        let vm = APODDailyViewModel(autoLoad: false, repository: mockRepo)
        if case .idle = vm.state { } else {
            XCTFail("Expected .idle, got \(vm.state)")
        }
    }
 
    func testOnAppearTriggersNetworkLoad() async {
        mockRepo.result = .success(APODResult(apod: .imageFixture, isCached: false))
        let vm = APODDailyViewModel(autoLoad: true, repository: mockRepo)
        vm.onAppear()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(mockRepo.fetchCallCount, 1)
    }
 
    func testOnAppearOnlyLoadsOnce() async {
        mockRepo.result = .success(APODResult(apod: .imageFixture, isCached: false))
        let vm = APODDailyViewModel(autoLoad: true, repository: mockRepo)
        vm.onAppear()
        vm.onAppear()
        vm.onAppear()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(mockRepo.fetchCallCount, 1)
    }
 
    func testSuccessfulLoadSetsContentState() async {
        mockRepo.result = .success(APODResult(apod: .imageFixture, isCached: false))
        let vm = APODDailyViewModel(autoLoad: false, repository: mockRepo)
        vm.load(date: nil)
        try? await Task.sleep(nanoseconds: 100_000_000)
        if case .content(let apod, let cached) = vm.state {
            XCTAssertEqual(apod.title, "Pillars of Creation")
            XCTAssertFalse(cached)
        } else {
            XCTFail("Expected .content, got \(vm.state)")
        }
    }
 
    func testFailedLoadSetsErrorState() async {
        mockRepo.result = .failure(APODError.badResponse(503))
        let vm = APODDailyViewModel(autoLoad: false, repository: mockRepo)
        vm.load(date: nil)
        try? await Task.sleep(nanoseconds: 100_000_000)
        if case .error(let message) = vm.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected .error, got \(vm.state)")
        }
    }
 
    func testCachedResultFlagIsPreserved() async {
        mockRepo.result = .success(APODResult(apod: .imageFixture, isCached: true))
        let vm = APODDailyViewModel(autoLoad: false, repository: mockRepo)
        vm.load(date: nil)
        try? await Task.sleep(nanoseconds: 100_000_000)
        if case .content(_, let cached) = vm.state {
            XCTAssertTrue(cached)
        } else {
            XCTFail("Expected .content, got \(vm.state)")
        }
    }
 
    func testVideoAPODLoadsCorrectMediaType() async {
        mockRepo.result = .success(APODResult(apod: .videoFixture, isCached: false))
        let vm = APODDailyViewModel(autoLoad: false, repository: mockRepo)
        vm.load(date: nil)
        try? await Task.sleep(nanoseconds: 100_000_000)
        if case .content(let apod, _) = vm.state, case .video = apod.media {
            // pass
        } else {
            XCTFail("Expected .content with .video media, got \(vm.state)")
        }
    }
 
    func testLoadForwardsSelectedDateToRepository() async {
        mockRepo.result = .success(APODResult(apod: .imageFixture, isCached: false))
        let vm = APODDailyViewModel(autoLoad: false, repository: mockRepo)
        let date = APODDateFormatter.parse("2021-04-01")
        vm.load(date: date)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(
            mockRepo.lastDateRequested.map { APODDateFormatter.format($0) },
            "2021-04-01"
        )
    }
}
 
