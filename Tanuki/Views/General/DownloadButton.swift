//
//  DownloadButton.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import SwiftUI

/// Downloads a file to the temporary cache, then opens the share sheet.
struct DownloadButton<Label: View>: View {
	private let url: URL
	private let fileName: String?
	@ViewBuilder private let label: () -> Label

	@State private var downloading = false

	init(url: URL, fileName: String? = nil, @ViewBuilder label: @escaping () -> Label) {
		self.url = url
		self.fileName = fileName
		self.label = label
	}

	private var downloadFileName: String {
		let candidate = fileName ?? url.lastPathComponent
		let name = URL(fileURLWithPath: candidate).lastPathComponent
		return name.isNotEmpty ? name : "download"
	}

	private func download() async {
		downloading = true
		defer { downloading = false }

		let name = downloadFileName

		do {
			FileCache.purge()

			let file = try await API.download(
				from: url,
				to: { _, _ in
					(
						FileCache.destination(for: name),
						[.createIntermediateDirectories, .removePreviousFile]
					)
				}
			)

			ShareSheet.present(for: file)
		} catch let error {
			Notify.status(.error, "Download failed", error.localizedDescription)
		}
	}

	public var body: some View {
		Button {
			Task {
				await download()
			}
		} label: {
			HStack {
				label()
				if downloading {
					Spacer()
					ProgressView()
						.controlSize(.small)
				}
			}
		}
		.disabled(downloading)
	}
}
