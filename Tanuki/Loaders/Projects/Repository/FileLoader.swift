//
//  FileLoader.swift
//  GitLab
//
//  Created by Felix Schindler on 02.11.21.
//

import AVKit
import SwiftUI

struct FileLoader: View {
	private let projectId: Int
	private let filePath: String
	private let fileExtension: String
	private let refName: String

	@Environment(\.colorScheme)
	private var colorScheme: ColorScheme

	@State
	private var file: Result<Data, Error>? = nil

	@State
	private var localURL: URL? = nil

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

	private func loadFile() async {
		do {
			let res = try await API.raw(
				method: .get,
				endpoint: "projects/\(projectId)/repository/files",
				resource: filePath,
				suffix: "/raw",
				query: ["ref": refName]
			)

			guard let data = res.data else {
				throw APIError.emptyResponse
			}

			self.file = .success(data)
			self.localURL = FileLoader.writeTemporaryFile(
				data,
				fileName: filePath.components(separatedBy: "/").last ?? filePath
			)
		} catch let error {
			self.file = .failure(error)
			self.localURL = nil
			Notify.status(.error)
		}
	}

	private var isPDF: Bool {
		Formats.pdfFormats.contains(fileExtension)
	}

	private static var temporaryDirectory: URL {
		FileManager.default.temporaryDirectory
			.appendingPathComponent("tanuki-files", isDirectory: true)
	}

	private static func writeTemporaryFile(_ data: Data, fileName: String) -> URL? {
		let directory = temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)

		do {
			try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
			let url = directory.appendingPathComponent(fileName)
			try data.write(to: url)
			purgeTemporaryFiles()
			return url
		} catch {
			return nil
		}
	}

	private static func purgeTemporaryFiles() {
		let staleBefore = Date().addingTimeInterval(-24 * 60 * 60)

		guard
			let entries = try? FileManager.default.contentsOfDirectory(
				at: temporaryDirectory,
				includingPropertiesForKeys: [.contentModificationDateKey]
			)
		else {
			return
		}

		for entry in entries {
			let modified = try? entry.resourceValues(forKeys: [.contentModificationDateKey])
				.contentModificationDate
			if let modified, modified < staleBefore {
				try? FileManager.default.removeItem(at: entry)
			}
		}
	}

	public var body: some View {
		Group {
			if isPDF {
				pdfPreview
			} else {
				ScrollView {
					VStack(alignment: .leading) {
						preview
						Spacer()
					}
					.padding(.horizontal)
					.frame(maxWidth: .infinity)
				}.refreshable {
					await loadFile()
				}
			}
		}.task {
			await loadFile()
		}.toolbar {
			if let localURL {
				ShareButton(localURL)
			}
		}.navigationTitle(filePath)
	}

	@ViewBuilder
	private var preview: some View {
		if Formats.audioFormats.contains(fileExtension) {
			unavailable("Can't preview this \(fileExtension) audio file", systemImage: "play")
		} else if Formats.videoFormats.contains(fileExtension) {
			videoPreview
		} else if Formats.imageFormats.contains(fileExtension) {
			imagePreview
		} else if isPDF {
			pdfPreview
		} else if Formats.binaryFormats.contains(fileExtension) {
			unavailable("Can't preview this \(fileExtension) file", systemImage: "doc.zipper")
		} else {
			textPreview
		}
	}

	@ViewBuilder
	private var imagePreview: some View {
		if let file {
			switch file {
			case .success(let data):
				if let image = UIImage(data: data) {
					Image(uiImage: image)
						.resizable()
						.scaledToFit()
						.cornerRadius(10)
				} else {
					unavailable("Can't preview this \(fileExtension) file", systemImage: "photo")
				}
			case .failure(let error):
				FailedView(error)
			}
		} else {
			LoadingView("Loading file", systemImage: "photo")
		}
	}

	@ViewBuilder
	private var videoPreview: some View {
		#if canImport(AVKit)
			if let localURL {
				VideoPlayer(player: AVPlayer(url: localURL))
			} else if let file {
				switch file {
				case .success:
					unavailable("Can't preview this \(fileExtension) video file", systemImage: "play")
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading file", systemImage: "play")
			}
		#else
			unavailable("Can't preview this \(fileExtension) video file", systemImage: "play")
		#endif
	}

	@ViewBuilder
	private var pdfPreview: some View {
		#if canImport(PDFKit)
			if let file {
				switch file {
				case .success:
					if let localURL {
						PDFPreview(url: localURL)
					} else {
						unavailable("Can't preview this \(fileExtension) file", systemImage: "doc.richtext")
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading file", systemImage: "doc.richtext")
			}
		#else
			unavailable("Can't preview this \(fileExtension) file", systemImage: "doc.richtext")
		#endif
	}

	@ViewBuilder
	private var textPreview: some View {
		if let file {
			switch file {
			case .success(let data):
				if let content = String(data: data, encoding: .utf8) {
					if fileExtension == "md" {
						Markdown(content.emojized())
					} else {
						CodeTextView(
							content,
							language: self.fileExtension,
							colorScheme: self.colorScheme,
							fontSize: 12
						)
					}
				} else {
					unavailable("Can't preview this \(fileExtension) file", systemImage: "document")
				}
			case .failure(let error):
				FailedView(error)
			}
		} else {
			LoadingView("Loading file", systemImage: "document")
		}
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
