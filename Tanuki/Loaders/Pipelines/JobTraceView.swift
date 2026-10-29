//
//  JobTraceView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import SwiftUI

struct JobTraceView: View {
	let fullPath: String
	let jobId: Int
	let jobName: String

	@State
	private var trace: Result<String, Error>? = nil

	private func loadTrace() async {
		do {
			let response = try await API.raw(
				method: .get,
				endpoint: "projects", resource: fullPath, suffix: "jobs/\(jobId)/trace")
			guard let data = response.data, let text = String(data: data, encoding: .utf8) else {
				throw APIError.emptyResponse
			}
			trace = .success(text)
		} catch {
			trace = .failure(error)
			Notify.status(.error)
		}
	}

	var body: some View {
		ScrollView {
			if let trace {
				switch trace {
				case .success(let text):
					if text.isEmpty {
						NoContentView("No log output", lucide: .fileText)
					} else {
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
				LoadingView("Loading log", lucide: .fileText)
			}
		}.task {
			await loadTrace()
		}.refreshable {
			await loadTrace()
		}.toolbar {
			if case .success(let text) = trace, text.isNotEmpty {
				Button("Copy log", lucide: .copy) {
					text.copyToClipboard()
					Notify.status(.success, "Copied to clipboard", systemImage: "checkmark")
				}
			}
		}.navigationTitle(jobName)
			.navigationBarTitleDisplayMode(.inline)
	}
}
