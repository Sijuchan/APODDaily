//
//  APODScreen.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//


import SwiftUI

struct APODDailyScreen: View {

    @ObservedObject var viewModel: APODDailyViewModel

    var body: some View {
        content
            .onAppear { viewModel.onAppear() }
    }
    

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("No content")

        case .loading:
            ProgressView()

        case .error(let message):
            Text(message)

        case .content(let apod, let cached):
            apodView(apod, cached: cached)
                .navigationTitle("Astronomy Picture of the Day")
                .navigationBarTitleDisplayMode(.inline)
        
        }
        
    }
    
    private func apodView(_ apod: APOD, cached: Bool) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                headerView(apod)
                mediaView(apod)
                explanationView(apod)

            }
            .padding()
        }
    }

    private func headerView(_ apod: APOD) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(apod.title)
                .font(.title2)
                .bold()
                .accessibilityAddTraits(.isHeader)

            Text(
                apod.date.formatted(
                    date: .long,
                    time: .omitted
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
    
    private func explanationView(_ apod: APOD) -> some View {
        Text(apod.explanation)
            .font(.body)
            .textSelection(.enabled)
    }
    
    private struct APODImageView: View {

        let imageData: Data?
        let fallbackURL: URL?

        var body: some View {
            Group {
                if let imageData,
                   let image = UIImage(data: imageData) {

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()

                } else if let fallbackURL {

                    AsyncImage(url: fallbackURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            placeholder
                        default:
                            ProgressView()
                        }
                    }

                } else {
                    placeholder
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

        }

        private var placeholder: some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
                .frame(height: 240)
                .overlay {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                }
        }
    }
    

    @ViewBuilder
    private func mediaView(_ apod: APOD) -> some View {
        switch apod.media {
        case .image(let data, let url):
            APODImageView(
                imageData: data,
                fallbackURL: url
            )

        case .video(let url, _):
            NavigationLink("Play Video") {
                WebVideoView(url: url)
            }
        }
    }
}



#Preview {
    NavigationStack {
        APODDailyScreen(
            viewModel: APODDailyViewModel(
                autoLoad: true,
                repository: MockAPODRepository()
            )
        )
    }
}
