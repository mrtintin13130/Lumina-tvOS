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
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailHero(playFocused: $playFocused, item: item)
                        .frame(width: geometry.size.width)

                    VStack(alignment: .leading, spacing: 46) {
                        DetailPeopleShelves(item: item)

                        if item.mediaType == "tv_show" {
                            TVSeasonEpisodeSection()
                        }

                        if appModel.isDetailLoading {
                            ProgressView("Loading details")
                                .font(.headline)
                                .padding(.vertical, 8)
                        }

                        StatusText(message: appModel.statusMessage)
                    }
                    .padding(.horizontal, 92)
                    .padding(.top, 18)
                    .padding(.bottom, 70)
                }
                .frame(width: geometry.size.width, alignment: .leading)
            }
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
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
            DetailBackdropImage(url: appModel.artworkURL(for: item.backdropPath ?? item.posterPath, kind: .backdrop))

            LinearGradient(
                colors: [
                    .black.opacity(0.98),
                    .black.opacity(0.74),
                    .black.opacity(0.28),
                    .black.opacity(0.08)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.1),
                    .black.opacity(0.96)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    .black.opacity(0.7),
                    .clear,
                    .black.opacity(0.86)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 14) {
                    DetailTitleMark(item: item)

                    DetailMetadataRow(values: item.detailMetadata)
                }

                if let overview = item.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.system(size: 25, weight: .regular))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(4)
                        .lineSpacing(4)
                        .frame(maxWidth: 960, alignment: .leading)
                }

                DetailHeroProgress(item: item)

                HStack(alignment: .center, spacing: 14) {
                    if item.mediaType == "movie" {
                        Button {
                            Task { await appModel.playCatalogMovie(item) }
                        } label: {
                            Label(item.primaryActionTitle, systemImage: "play.fill")
                                .font(.system(size: 22, weight: .bold))
                                .frame(minWidth: 170)
                        }
                        .buttonStyle(DetailActionButtonStyle(isPrimary: true))
                        .disabled(item.hasPlayableMedia == false)
                        .focused($playFocused)
                        .scaleEffect(playFocused ? 1.06 : 1)
                        .shadow(color: .white.opacity(playFocused ? 0.34 : 0), radius: 18, x: 0, y: 0)
                        .animation(.easeOut(duration: 0.16), value: playFocused)
                    }

                    if item.primaryTrailerTitle != nil {
                        Button {
                            appModel.openTrailer(item)
                        } label: {
                            Label(item.trailerActionTitle, systemImage: "film.stack")
                                .font(.system(size: 22, weight: .bold))
                                .frame(minWidth: 150)
                        }
                        .buttonStyle(DetailActionButtonStyle(isPrimary: false))
                    }
                }
            }
            .padding(.horizontal, 92)
            .padding(.bottom, 78)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 820)
        .clipped()
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
    }
}

private struct DetailBackdropImage: View {
    let url: URL?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)

            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.28))
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "play.rectangle")
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.28))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 820)
        .clipped()
    }
}

private struct DetailTitleMark: View {
    @EnvironmentObject private var appModel: AppModel
    let item: CatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let logoURL = appModel.artworkURL(for: item.logoPath, kind: .logo) {
                AsyncImage(url: logoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        titleText
                    }
                }
                .frame(maxWidth: 620, maxHeight: 180, alignment: .leading)
            } else {
                titleText
            }

            Text(item.mediaTypeDisplayName.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.58))
                .tracking(1.6)
        }
    }

    private var titleText: some View {
        Text(item.title)
            .font(.system(size: 68, weight: .bold))
            .lineLimit(2)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: 960, alignment: .leading)
    }
}

private struct DetailHeroProgress: View {
    let item: CatalogItem

    var body: some View {
        if item.progressPercent > 0 {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(Int(item.progressPercent.rounded()))% watched")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))

                ProgressView(value: min(max(item.progressPercent / 100, 0), 1))
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .frame(width: 420)
            }
            .padding(.top, 2)
        }
    }
}

private struct DetailPeopleShelves: View {
    let item: CatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 34) {
            if !item.cast.isEmpty {
                DetailPersonShelf(title: "Cast", people: item.cast)
            }

            if !item.behindTheScenesPeople.isEmpty {
                DetailPersonShelf(title: "Behind the Scenes", people: item.behindTheScenesPeople)
            }

            if item.cast.isEmpty && item.behindTheScenesPeople.isEmpty {
                DetailEmptyPeopleShelf()
            }
        }
    }
}

private struct DetailActionButtonStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isPrimary ? .black : .white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(
                isPrimary ? .white.opacity(configuration.isPressed ? 0.78 : 0.94) : .white.opacity(0.1),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(.white.opacity(isPrimary ? 0 : 0.14), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private struct DetailPersonShelf: View {
    let title: String
    let people: [CatalogPersonCredit]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())

            ScrollView(.horizontal) {
                LazyHStack(spacing: 18) {
                    ForEach(people.prefix(18)) { person in
                        DetailPersonButton(person: person)
                    }
                }
                .padding(.vertical, 8)
            }
            .scrollClipDisabled()
        }
    }
}

private struct DetailPersonButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let person: CatalogPersonCredit

    var body: some View {
        Button {
            appModel.statusMessage = "\(person.name) details are not wired yet."
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                CatalogArtwork(
                    url: appModel.artworkURL(for: person.profilePath, kind: .poster),
                    aspectRatio: 2 / 3
                )
                .frame(width: 150, height: 225)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(person.name)
                        .font(.headline.weight(.semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    if let role = person.role ?? person.department {
                        Text(role)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.white.opacity(0.58))
                            .lineLimit(1)
                    }
                }
                .frame(width: 150, alignment: .leading)
            }
            .padding(10)
            .background(.white.opacity(isFocused ? 0.18 : 0.04), in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(isFocused ? 0.82 : 0.08), lineWidth: isFocused ? 2 : 1)
            }
            .scaleEffect(isFocused ? 1.06 : 1)
            .animation(.easeOut(duration: 0.16), value: isFocused)
        }
        .buttonStyle(.plain)
        .focused($isFocused)
    }
}

private struct DetailEmptyPeopleShelf: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.title2.bold())

            Text("Cast and behind-the-scenes credits are not available for this title yet.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.62))
                .padding(.vertical, 18)
        }
    }
}

private struct DetailMetadataRow: View {
    let values: [String]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(values, id: \.self) { value in
                Text(value)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.74))
                    .lineLimit(1)

                if value != values.last {
                    Circle()
                        .fill(.white.opacity(0.36))
                        .frame(width: 5, height: 5)
                }
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
                            DetailSeasonButton(
                                season: season,
                                isSelected: appModel.selectedSeasonNumber == season.seasonNumber
                            )
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

private struct DetailSeasonButton: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFocused: Bool

    let season: TVSeasonSummary
    let isSelected: Bool

    var body: some View {
        Button {
            Task { await appModel.selectTVSeason(season) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "rectangle.stack")
                    .font(.headline.weight(.semibold))
                Text(season.title)
                    .font(.headline.weight(.semibold))
            }
            .frame(minWidth: 150)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                isSelected ? .white.opacity(0.2) : .white.opacity(0.08),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(
                        isFocused ? .white.opacity(0.85) : .white.opacity(isSelected ? 0.38 : 0.12),
                        lineWidth: isFocused ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .focusable(true)
        .focused($isFocused)
    }
}

private extension CatalogItem {
    var primaryActionTitle: String {
        if progressPercent > 0 {
            return "Resume"
        }
        return "Play"
    }

    var trailerActionTitle: String {
        "Trailer"
    }

    var behindTheScenesPeople: [CatalogPersonCredit] {
        crew.filter { credit in
            guard let label = credit.role?.lowercased() ?? credit.department?.lowercased() else {
                return true
            }
            return !label.contains("cast")
        }
    }
}
