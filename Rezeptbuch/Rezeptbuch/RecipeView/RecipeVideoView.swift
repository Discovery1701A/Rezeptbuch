//
//  RecipeVideoView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import SwiftUI
/// Zeigt ein eingebettetes YouTube-Video basierend auf einem Link an.
/// Unterstützt sowohl normale YouTube-URLs als auch Kurzlinks.
struct RecipeVideoView: View {
    var videoLink: String?  // Der Link zum YouTube-Video (optional)

    /// Extrahiert die YouTube-Video-ID aus einem YouTube-Link.
    /// - Parameter link: Der vollständige YouTube-Link.
    /// - Returns: Die extrahierte Video-ID oder `nil`, falls keine gültige ID gefunden wurde.
    func extractYouTubeID(from link: String) -> String? {
        if link.contains("youtube.com"),
           let url = URL(string: link),
           let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems {
            // Normale YouTube-Links (z. B. https://www.youtube.com/watch?v=VIDEO_ID)
            return queryItems.first(where: { $0.name == "v" })?.value
        } else if link.contains("youtu.be") {
            // Kurzlinks (z. B. https://youtu.be/VIDEO_ID)
            return URL(string: link)?.lastPathComponent
        }
        return nil
    }

    var body: some View {
        if let link = videoLink, let videoID = extractYouTubeID(from: link) {
            // ✅ Gültiger Link: YouTube-Video anzeigen
            YouTubeView(videoID: videoID)
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 300)
        } else {
            if videoLink != nil {
                // ⚠️ Ungültiger Link: Fehlermeldung anzeigen
                Text("Kein gültiges Video gefunden.")
                    .foregroundColor(.red)
            }
        }
    }
}
