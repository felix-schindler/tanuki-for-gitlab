//
//  DiffsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.03.24.
//

import GitLabAPI
import SwiftUI

struct DiffsStatsLoader: View {
	private let fullPath: String
	private let iid: String

	@State
	private var loader = ApolloLoader<
		MergeRequestDiffsQuery, [MergeRequestDiffsQuery.Data.Project.MergeRequest.DiffStat]
	> {
		$0.project?.mergeRequest?.diffStats
	}

	init(fullPath: String, iid: String) {
		self.fullPath = fullPath
		self.iid = iid
	}

	public var body: some View {
		let state = loader.state

		List {
			if state.isInitialLoading {
				LoadingView("Loading file diffs", systemImage: Icons.diffStats.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let diffs = state.value {
				if diffs.isEmpty {
					NoContentView(
						"There are no files with changed content", systemImage: Icons.diffStats.rawValue)
				} else {
					ForEach(diffs, id: \.path) { diff in
						VStack(alignment: .leading) {
							Text(diff.path)
							ScrollView(.horizontal) {
								HStack {
									PillView(
										"+\(diff.additions)", bgColor: .green, fgColor: .white)
									PillView(
										"-\(diff.deletions)", bgColor: .red, fgColor: .white)
								}.font(.system(.body, design: .monospaced))
							}
						}
					}
				}
			}

		}.task {
			await loader.load(MergeRequestDiffsQuery(fullPath: fullPath, iid: iid))
		}.refreshable {
			await loader.reload(MergeRequestDiffsQuery(fullPath: fullPath, iid: iid))
		}.navigationTitle("Diffs")
	}
}

#Preview {
	NavigationStack {
		DiffsStatsLoader(fullPath: "felix-schindler/gitlab-ios", iid: "1")
	}
}
