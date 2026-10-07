//
//  PDFPreview.swift
//  Tanuki
//
//  Created by Felix Schindler on 01.10.26.
//

import PDFKit
import SwiftUI

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
		guard pdfView.document?.documentURL != url else { return }
		pdfView.document = PDFDocument(url: url)
	}
}
