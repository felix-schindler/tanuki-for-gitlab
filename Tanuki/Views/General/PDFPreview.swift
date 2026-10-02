//
//  PDFPreview.swift
//  Tanuki
//
//  Created by Felix Schindler on 01.10.26.
//

#if canImport(PDFKit)

	import PDFKit
	import SwiftUI

	/// Renders a PDF file with PDFKit's own viewer, which brings page navigation,
	/// zooming and text selection instead of us rasterising pages ourselves.
	struct PDFPreview: UIViewRepresentable {
		private let url: URL

		init(url: URL) {
			self.url = url
		}

		public func makeUIView(context: Context) -> PDFView {
			let pdfView = PDFView()
			pdfView.autoScales = true
			pdfView.displayMode = .singlePageContinuous
			pdfView.displayDirection = .vertical
			pdfView.backgroundColor = .clear
			return pdfView
		}

		public func updateUIView(_ pdfView: PDFView, context: Context) {
			// `updateUIView` runs on every state change, so only reparse when the
			// document actually changed — otherwise this resets the scroll position.
			guard pdfView.document?.documentURL != url else { return }
			pdfView.document = PDFDocument(url: url)
		}
	}

#endif
