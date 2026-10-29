//
//  FileLoader.swift
//  GitLab
//
//  Created by Felix Schindler on 02.11.21.
//

import AVKit
import SwiftUI

struct FileLoader: View {
	private static let confirmThreshold: Int64 = 3 * 1024 * 1024

	private enum Phase {
		case loading
		case ready(size: Int64)
		case downloading(received: Int64, total: Int64)
		case loaded
		case failed(Error)
	}

	private let projectId: Int
	private let filePath: String
	private let fileExtension: String
	private let refName: String

	@Environment(\.colorScheme)
	private var colorScheme: ColorScheme

	@State
	private var phase: Phase = .loading

	@State
	private var localURL: URL? = nil

	/// Resolved once per download — reading these in `body` would hit the disk on
	/// every re-evaluation.
	@State
	private var text: String? = nil

	@State
	private var image: UIImage? = nil

	init(
		id: Int,
		filePath: String,
		refName: String
	) {
		self.projectId = id
		self.filePath = filePath
		self.refName = refName
		self.fileExtension = filePath.components(separatedBy: ".").last?.lowercased() ?? ""
	}

	private var fileName: String {
		filePath.components(separatedBy: "/").last ?? filePath
	}

	private var isPDF: Bool {
		Formats.pdfFormats.contains(fileExtension)
	}

	private var isVideo: Bool {
		Formats.videoFormats.contains(fileExtension)
	}

	private var icon: String {
		if Formats.audioFormats.contains(fileExtension) || isVideo {
			return "play"
		} else if Formats.imageFormats.contains(fileExtension) {
			return "photo"
		} else if isPDF {
			return "doc.richtext"
		} else {
			return "document"
		}
	}

	private var isLoaded: Bool {
		if case .loaded = phase {
			return true
		}
		return false
	}

	private func probe() async {
		// Still on disk? Reuse it. This also covers a file that was cleared from
		// Settings while this screen was open (e.g. iPad Split View).
		if let localURL, FileManager.default.fileExists(atPath: localURL.path) {
			phase = .loaded
			return
		}

		self.localURL = nil
		self.image = nil
		self.text = nil

		phase = .loading

		do {
			let res = try await API.raw(
				method: .head,
				endpoint: "projects/\(projectId)/repository/files",
				resource: filePath,
				suffix: "/raw",
				query: ["ref": refName]
			)

			let size = res.response?.value(forHTTPHeaderField: "X-Gitlab-Size")
				.flatMap { Int64($0) }

			// No size to show, so we can't ask — just download it.
			guard let size, size >= Self.confirmThreshold else {
				await loadFile()
				return
			}

			phase = .ready(size: size)
		} catch {
			await loadFile()
		}
	}

	private func loadFile() async {
		if !isLoaded {
			phase = .loading
		}
		let name = fileName

		do {
			let url = try await API.download(
				to: { _, _ in
					(
						FileCache.destination(for: name),
						[.createIntermediateDirectories, .removePreviousFile]
					)
				},
				method: .get,
				endpoint: "projects/\(projectId)/repository/files",
				resource: filePath,
				suffix: "/raw",
				query: ["ref": refName],
				onProgress: { received, total in
					// Below the threshold a file arrives instantly, so don't flash a
					// bar at it — and a refresh keeps the existing preview visible.
					guard total >= Self.confirmThreshold, !self.isLoaded else {
						return
					}
					self.phase = .downloading(received: received, total: total)
				}
			)

			FileCache.purge()
			self.localURL = url
			self.resolvePreview(from: url)
			self.phase = .loaded
		} catch let error {
			self.localURL = nil
			self.image = nil
			self.text = nil
			self.phase = .failed(error)
			Notify.status(.error)
		}
	}

	private func resolvePreview(from url: URL) {
		if isPDF || isVideo {
			self.image = nil
			self.text = nil
		} else if Formats.imageFormats.contains(fileExtension) {
			self.image = UIImage(contentsOfFile: url.path)
			self.text = nil
		} else {
			self.image = nil
			self.text = (try? String(contentsOf: url, encoding: .utf8))
		}
	}

	public var body: some View {
		SwiftUI.Group {
			if case .failed(let error) = phase {
				FailedView(error)
			} else if Formats.audioFormats.contains(fileExtension) {
				unavailable("Can't preview this \(fileExtension) audio file", systemImage: "play")
			} else if Formats.binaryFormats.contains(fileExtension) {
				unavailable("Can't preview this \(fileExtension) file", systemImage: "doc.zipper")
			} else if isLoaded, let localURL {
				if isPDF {
					PDFPreview(url: localURL)
				} else {
					ScrollView {
						VStack(alignment: .leading) {
							preview(localURL)
							Spacer()
						}
						.padding(.horizontal)
						.frame(maxWidth: .infinity)
					}.refreshable {
						await loadFile()
					}
				}
			} else {
				pending
			}
		}.task {
			await probe()
		}.toolbar {
			if let localURL {
				ShareButton(localURL)
			}
		}.navigationTitle(filePath)
	}

	@ViewBuilder
	private func preview(_ url: URL) -> some View {
		if isVideo {
			VideoPlayer(player: AVPlayer(url: url))
		} else if Formats.imageFormats.contains(fileExtension) {
			if let image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.cornerRadius(10)
			} else {
				unavailable("Can't preview this \(fileExtension) file", systemImage: "photo")
			}
		} else {
			textPreview
		}
	}

	@ViewBuilder
	private var textPreview: some View {
		if let text {
			if fileExtension == "md" {
				Markdown(text)
			} else {
				CodeTextView(
					text,
					language: self.fileExtension,
					colorScheme: self.colorScheme,
					fontSize: 12
				)
			}
		} else {
			unavailable("Can't preview this \(fileExtension) file", systemImage: "document")
		}
	}

	@ViewBuilder
	private var pending: some View {
		VStack(spacing: 12) {
			Image(systemName: icon)
				.resizable()
				.scaledToFit()
				.foregroundStyle(.gray)
				.frame(width: 50, height: 50)

			switch phase {
			case .ready(let size):
				Text(size.formatted(.byteCount(style: .file)))
					.font(.title2.bold())
				Button {
					Task {
						await loadFile()
					}
				} label: {
					Label("Download", systemImage: "arrow.down.circle")
				}
				.adaptiveButtonStyleProminent()
			case .downloading(let received, let total):
				ProgressView(value: Double(received) / Double(total))
					.frame(maxWidth: 220)
				Text("\(received.formatted(.byteCount(style: .file))) of \(total.formatted(.byteCount(style: .file)))")
					.font(.callout)
					.monospacedDigit()
			default:
				ProgressView()
			}
		}
		.padding()
		.frame(maxWidth: .infinity, minHeight: 100)
	}

	private func unavailable(_ message: String, systemImage: String) -> some View {
		VStack {
			Image(systemName: systemImage)
				.resizable()
				.scaledToFit()
				.foregroundStyle(.gray)
				.frame(width: 50, height: 50)
			Text(message)
		}
	}
}

#Preview {
	VStack {
		FileLoader(
			id: 33_025_310,
			filePath: "GitLab/GitLabApp.swift",
			refName: "main"
		)
		FileLoader(
			id: 45_748_717,
			filePath: "tanuki.svg",
			refName: "main"
		)
	}
}
