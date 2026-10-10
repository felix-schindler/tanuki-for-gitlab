//
//  TodoView.swift
//  Tanuki
//
//  Created by Felix Schindler on 09.03.24.
//

import GitLabAPI
import SwiftUI

struct TodoView: View {
	private let todo: Todo

	init(_ todo: Todo) {
		self.todo = todo
	}

	private func markDone() async {
		do {
			let result = try await Network.shared.apollo.perform(mutation: MarkTodoDoneMutation(id: todo.id))
			if let errors = result.data?.todoMarkDone?.errors, errors.isNotEmpty {
				Notify.status(
					.error, "Failed to mark todo as done", errors.joined(separator: ", "), systemImage: "xmark")
			} else {
				Notify.status(.success, "Todo marked as done", systemImage: "checkmark")
			}
		} catch let error {
			Notify.status(.error, "Failed to mark todo as done", error.localizedDescription, systemImage: "xmark")
		}
	}

	public var body: some View {
		if let fullPath = todo._project?.fullPath,
			let iid = todo._webUrl?.toIntId()
		{
			if todo.targetType == .issue {
				NavigationLink(
					destination: IssueLoader(fullPath: fullPath, iid: String(iid)),
					label: {
						main
					}
				)
			} else if todo.targetType == .mergerequest {
				NavigationLink(
					destination: MergeRequestLoader(fullPath: fullPath, iid: String(iid)),
					label: {
						main
					}
				)
			} else {
				main
			}
		} else {
			main
		}
	}

	private var main: some View {
		VStack(alignment: .leading) {
			ScrollView(.horizontal) {
				HStack {
					PillView(
						todo.state.rawValue.capitalized,
						bgColor: (todo.state == .done ? .blue : .green),
						fgColor: .white
					)
					PillView(
						"\(todo.targetType.rawValue.lowercased().capitalized) · \(todo.action.rawValue.replacing("_", with: " "))"
					)
					PillView(Date.fromToString(todo.createdAt), icon: "clock")
				}
			}.font(.footnote)

			Markdown(todo.body)

			ScrollView(.horizontal) {
				HStack {
					AuthorView(todo._author)

					if let project = todo._project {
						SmallProjectView(project, avatarSize: .tiny)
							.padding(.horizontal, 8)
							.padding(.vertical, 3)
							.background(Color(.systemGray5))
							.foregroundStyle(.primary)
							.cornerRadius(5)
					}

					if let groupPath = todo._groupPath {
						NavigationLink(
							destination: GroupLoader(fullPath: groupPath),
							label: {
								PillView(groupPath)
							})
					}
				}
			}.font(.footnote)
		}.swipeActions {
			if todo.state != .done {
				Button("Mark done", systemImage: "checkmark") {
					Task {
						await markDone()
					}
				}.tint(.green)
			}
			if let webUrl = todo._webUrl,
				let url = URL(string: webUrl)
			{
				ShareButton(url)
			}
		}
	}
}
