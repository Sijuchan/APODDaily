//
//  WebVideoView.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//


import SwiftUI
import WebKit

struct WebVideoView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ view: WKWebView, context: Context) {
        view.load(URLRequest(url: url))
    }
}
