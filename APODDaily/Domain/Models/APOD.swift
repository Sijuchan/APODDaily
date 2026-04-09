//
//  APOD.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation

import Foundation

struct APOD: Equatable {
    let title: String
    let explanation: String
    let date: Date
    let media: Media

    enum Media: Equatable {
        case image(Data?, URL?)
        case video(URL, thumbnailURL: URL?)
    }
}


extension APOD {
    static let preview = APOD(
        title: "Pillars of Creation",
        explanation: """
        This iconic image from NASA's James Webb Space Telescope shows the Pillars of Creation, \
        towering columns of interstellar gas and dust where new stars are forming.
        """,
        date: ISO8601DateFormatter().date(from: "2021-04-01T00:00:00Z") ?? .now,
        media: .image(
            nil,
            URL(string: "https://apod.nasa.gov/apod/image/2603/cg4.jpg")
        )
    )
}
