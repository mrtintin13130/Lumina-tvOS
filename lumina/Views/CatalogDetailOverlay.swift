//
//  CatalogDetailOverlay.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

struct CatalogDetailPage: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var playFocused: Bool

    let item: CatalogItem

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 32) {
                DetailHero(playFocused: $playFocused, item: item)

                if item.mediaType == "tv_show" {
                    TVSeasonEpisodeSection()
                }

                if appModel.isDetailLoading {
                    ProgressView("Loading details")
                }

                StatusText(message: appModel.statusMessage)
            }
            .padding(.horizontal, 80)
            .padding(.vertical, 54)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(item.title)
        .onAppear {
            playFocused = item.mediaType == "movie" && item.hasPlayableMedia != false
        }
    }
}

private struct DetailHero: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState.Binding var playFocused: Bool

    let item: CatalogItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CatalogArtwork(
                url: appModel.artworkURL(for: item.backdropPath ?? item.posterPath, kind: .backdrop),
                aspectRatio: 16 / 9
            )
            .frame(maxWidth: .infinity)
            .frame(height: 560)

            LinearGradient(
                colors: [
                    .black.opacity(0.86),
                    .black.opacity(0.44),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.92)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            HStack(alignment: .bottom, spacing: 32) {
                CatalogArtwork(
                    url: appModel.artworkURL(for: item.posterPath ?? item.backdropPath, kind: .poster),
                    aspectRatio: 2 / 3
                )
                .frame(width: 250, height: 375)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 14)

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 58, weight: .bold))
                            .lineLimit(2)

                        Text(item.subtitle ?? item.mediaTypeDisplayName)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    if !item.detailMetadata.isEmpty {
                        DetailMetadataRow(values: item.detailMetadata)
                    }

                    if let overview = item.overview, !overview.isEmpty {
                        Text(overview)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(5)
                            .frame(maxWidth: 900, alignment: .leading)
                    }

                    HStack(spacing: 14) {
                        if item.mediaType == "movie" {
                            Button {
                                Task { await appModel.playCatalogMovie(item) }
                            } label: {
                                Label(item.progressPercent > 0 ? "Resume" : "Play", systemImage: "play.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(item.hasPlayableMedia == false)
                            .focused($playFocused)
                        }

                        DetailStateBadge(title: "Playable", value: item.hasPlayableMedia == false ? "No" : "Yes")

                        if let watchlist = item.isWatchlisted {
                            DetailStateBadge(title: "Watchlist", value: watchlist ? "Added" : "Not added")
                        }

                        if let favorite = item.isFavorite {
                            DetailStateBadge(title: "Favorite", value: favorite ? "Yes" : "No")
                        }
                    }

                    if let trailer = item.primaryTrailerTitle {
                        Label(trailer, systemImage: "film.stack")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(38)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 560)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct DetailMetadataRow: View {
    let values: [String]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(values, id: \.self) { value in
                Text(value)
                    .font(.callout.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.13), in: Capsule())
            }
        }
    }
}

private struct TVSeasonEpisodeSection: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Seasons")
                .font(.title2.bold())

            if appModel.selectedTVSeasons.isEmpty && !appModel.isDetailLoading {
                EmptyCatalogState(title: "No seasons found")
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 14) {
                        ForEach(appModel.selectedTVSeasons) { season in
                            Button {
                                Task { await appModel.selectTVSeason(season) }
                            } label: {
                                Text(season.title)
                            }
                            .buttonStyle(.bordered)
                            .tint(appModel.selectedSeasonNumber == season.seasonNumber ? .white : .gray)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .scrollClipDisabled()
            }

            if !appModel.selectedTVEpisodes.isEmpty {
                CatalogShelfView(title: "Episodes", items: appModel.selectedTVEpisodes)
            } else if appModel.selectedSeasonNumber != nil && !appModel.isDetailLoading {
                EmptyCatalogState(title: "No episodes found")
            }
        }
    }
}

private struct DetailStateBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.callout.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}
