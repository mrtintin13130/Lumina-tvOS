//
//  CatalogDetailOverlay.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

struct CatalogDetailOverlay: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var closeFocused: Bool

    let item: CatalogItem

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.94)
                .ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 28) {
                    HStack(alignment: .top, spacing: 32) {
                        CatalogArtwork(
                            url: appModel.artworkURL(for: item.posterPath ?? item.backdropPath, kind: .poster),
                            aspectRatio: 2 / 3
                        )
                        .frame(width: 300, height: 450)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(item.title)
                                        .font(.system(size: 54, weight: .bold))
                                        .lineLimit(2)

                                    Text(item.subtitle ?? item.mediaTypeDisplayName)
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.7))
                                }

                                Spacer()

                                Button {
                                    appModel.closeCatalogDetail()
                                } label: {
                                    Label("Close", systemImage: "xmark.circle")
                                }
                                .buttonStyle(.bordered)
                                .focused($closeFocused)
                            }

                            if !item.detailMetadata.isEmpty {
                                HStack(spacing: 10) {
                                    ForEach(item.detailMetadata, id: \.self) { value in
                                        Text(value)
                                            .font(.callout.weight(.semibold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(.white.opacity(0.11), in: Capsule())
                                    }
                                }
                            }

                            if let overview = item.overview, !overview.isEmpty {
                                Text(overview)
                                    .font(.title3)
                                    .foregroundStyle(.white.opacity(0.78))
                                    .lineLimit(6)
                                    .frame(maxWidth: 920, alignment: .leading)
                            }

                            HStack(spacing: 14) {
                                Button {
                                    Task { await appModel.playCatalogMovie(item) }
                                } label: {
                                    Label(item.progressPercent > 0 ? "Resume" : "Play", systemImage: "play.fill")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(item.hasPlayableMedia == false)

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
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                    }

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
        }
        .onAppear {
            closeFocused = true
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
