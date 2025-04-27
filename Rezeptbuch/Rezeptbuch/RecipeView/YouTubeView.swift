//
//  YouTubeView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import Foundation
import SwiftUI
import WebKit


/// Stellt ein eingebettetes YouTube-Video dar.
struct YouTubeView: UIViewRepresentable {
    var videoID: String  // ID des YouTube-Videos

    /// Erstellt die `WKWebView`, um das Video anzuzeigen.
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    /// Aktualisiert die Ansicht mit der YouTube-URL.
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") else { return }
        uiView.scrollView.isScrollEnabled = false  // Deaktiviert Scrollen
        uiView.load(URLRequest(url: url))
    }
}

