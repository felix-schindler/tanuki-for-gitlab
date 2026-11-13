//
//  JobTraceView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import Alamofire
import SwiftUI

struct JobTraceView: View {
	let fullPath: String
	let jobId: Int
	let jobName: String

	private static let chunkSize = 256 * 1024

	@State
	private var trace: Result<String, Error>? = nil

	/// Byte offset of the first loaded line; 0 means the whole log is shown.
	@State
	private var firstLoadedByte = 0

	@State
	private var isLoadingOlder = false

	/// Bytes at the start of the shown text whose UTF-8 character started in an
	/// older chunk; they are prepended to the next older chunk instead of a `�`.
	@State
	private var seam = Data()

	private func loadTrace() async {
		do {
			let response = try await API.raw(
				method: .get,
				endpoint: "projects", resource: fullPath, suffix: "jobs/\(jobId)/trace",
				headers: ["Range": "bytes=-\(Self.chunkSize)"])
			firstLoadedByte = Self.rangeStart(response) ?? 0
			let (partial, text) = Self.splitLeadingPartial(response.data ?? Data())
			seam = partial
			trace = .success(text)
		} catch {
			trace = .failure(error)
			Notify.status(.error)
		}
	}

	private func loadOlder() async {
		guard firstLoadedByte > 0, case .success(let current) = trace else { return }
		isLoadingOlder = true
		defer { isLoadingOlder = false }

		let end = firstLoadedByte - 1
		let start = max(0, firstLoadedByte - Self.chunkSize)
		do {
			let response = try await API.raw(
				method: .get,
				endpoint: "projects", resource: fullPath, suffix: "jobs/\(jobId)/trace",
				headers: ["Range": "bytes=\(start)-\(end)"])
			firstLoadedByte = Self.rangeStart(response) ?? start
			let (partial, older) = Self.splitLeadingPartial((response.data ?? Data()) + seam)
			seam = partial
			trace = .success(older + current)
		} catch {
			Notify.status(.error)
		}
	}

	/// Splits off bytes at the start of `data` that continue a character from the
	/// previous chunk, so decoding neither loses nor mangles the boundary.
	private static func splitLeadingPartial(_ data: Data) -> (Data, String) {
		let base = data.startIndex
		let limit = min(3, data.count)
		var partial = 0
		while partial < limit, data[base + partial] & 0b1100_0000 == 0b1000_0000 {
			partial += 1
		}
		return (Data(data[base..<(base + partial)]), String(decoding: data[(base + partial)...], as: UTF8.self))
	}

	/// Parses the start offset of a `Content-Range: bytes 0-99/100` response.
	private static func rangeStart(_ response: AFDataResponse<Data>) -> Int? {
		guard let value = response.response?.value(forHTTPHeaderField: "Content-Range"),
			let range = value.split(separator: " ").last?.split(separator: "/").first,
			let start = range.split(separator: "-").first
		else {
			return nil
		}
		return Int(start)
	}

	var body: some View {
		ScrollView {
			if let trace {
				switch trace {
				case .success(let text):
					if text.isEmpty {
						NoContentView("No log output", systemImage: Icons.files.rawValue)
					} else {
						if firstLoadedByte > 0 {
							Button("Load older", systemImage: "arrow.up") {
								Task {
									await loadOlder()
								}
							}
							.disabled(isLoadingOlder)
							.padding(.horizontal)
						}
						Text(text)
							.font(.system(.caption, design: .monospaced))
							.textSelection(.enabled)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.horizontal)
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading log", systemImage: Icons.files.rawValue)
			}
		}.task {
			await loadTrace()
		}.refreshable {
			await loadTrace()
		}.toolbar {
			if case .success(let text) = trace, text.isNotEmpty {
				Button("Copy log", systemImage: Icons.copy.rawValue) {
					text.copyToClipboard()
					Notify.status(.success, "Copied to clipboard", systemImage: "checkmark")
				}
			}
		}.navigationTitle(jobName)
			.navigationBarTitleDisplayMode(.inline)
	}
}
