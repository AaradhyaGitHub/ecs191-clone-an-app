import SwiftUI
import CoreLocation

/// Full-screen search for campus buildings (Screen 3).
struct SearchView: View {
    let landmarks: [Landmark]
    let userLocation: CLLocationCoordinate2D?
    let onPick: (Landmark) -> Void
    let onCancel: () -> Void

    @State private var query = ""
    @FocusState private var fieldFocused: Bool

    private var results: [LandmarkSearch.Match] {
        LandmarkSearch.matches(landmarks, query: query, from: userLocation)
    }

    private var isQueryEmpty: Bool {
        query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 8) {
            searchRow
            ScrollView {
                VStack(spacing: 0) {
                    if landmarks.isEmpty {
                        message(
                            icon: "mappin.slash",
                            title: "No campus buildings yet",
                            text: "Building locations haven't been added to the app yet. Use “Find student parking near me” for now."
                        )
                    } else if results.isEmpty {
                        message(
                            icon: "text.magnifyingglass",
                            title: "No campus building found",
                            text: "Try a building name like “Olson” or a nickname like “MU”. Only UC Davis campus places are listed."
                        )
                    } else {
                        if isQueryEmpty { popularHeader }
                        LazyVStack(spacing: 0) {
                            ForEach(results) { match in
                                LandmarkRow(match: match) { onPick(match.landmark) }
                                Divider().overlay(Theme.hairline)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.top, 8)
        .background(Theme.screen.ignoresSafeArea())
        .onAppear { fieldFocused = true }
    }

    private var searchRow: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.accentText)
                TextField("Search UC Davis buildings…", text: $query)
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .tint(Theme.accentText)
                    .focused($fieldFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit { if let first = results.first { onPick(first.landmark) } }
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Theme.clearIcon)
                            .frame(width: 36, height: 36)
                    }
                    .accessibilityLabel("Clear search")
                    .transition(.opacity.combined(with: .scale(scale: 0.6)))
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 6)
            .frame(height: 46)
            .background(Theme.fieldFill, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.accentText, lineWidth: 2))
            .animation(.easeOut(duration: 0.15), value: query.isEmpty)

            Button("Cancel", action: onCancel)
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(Theme.accentText)
                .frame(minHeight: 44)
        }
        .padding(.horizontal, 16)
    }

    private var popularHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Popular on campus")
                .font(.system(.footnote, weight: .bold))
                .tracking(0.6)
                .textCase(.uppercase)
            Spacer()
            Text(userLocation == nil ? "A to Z" : "Nearest first")
                .font(.footnote)
        }
        .foregroundStyle(Theme.inkSecondary)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    private func message(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Theme.inkSecondary)
                .frame(width: 56, height: 56)
                .background(Theme.skeletonSoft, in: RoundedRectangle(cornerRadius: 16))
            Text(title)
                .font(.system(.title3, weight: .bold))
                .foregroundStyle(Theme.ink)
                .padding(.top, 4)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .lineSpacing(2)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .padding(.top, 64)
        .accessibilityElement(children: .combine)
    }
}
