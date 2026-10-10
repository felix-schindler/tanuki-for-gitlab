//
//  CurrentUserTodosLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.03.24.
//

import GitLabAPI
import SwiftUI

struct CurrentUserTodosLoader: View {
	@State
	private var todos: Result<[Todo?], Error>? = nil

	private func loadTodos() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: CurrentUserTodosQuery(), cachePolicy: .cacheAndNetwork)

			Task {
				for try await response in responses {
					if let todos = response.data?.currentUser?.todos?.nodes {
						self.todos = .success(todos)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			todos = .failure(error)
			Notify.status(.error)
		}
	}

	public func reloadTodos() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: CurrentUserTodosQuery(), cachePolicy: .networkOnly)

			if let todos = response.data?.currentUser?.todos?.nodes {
				self.todos = .success(todos)
			}

			Notify.status(.success)
		} catch let error {
			todos = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let todos {
				switch todos {
				case .success(let todos):
					if todos.isEmpty {
						NoContentView(
							"All caught up!",
							lucide: .squareCheckBig,
							description: "There are no Todos"
						)
					} else {
						ForEach(todos, id: \.?.id) { maybeTodo in
							if let todo = maybeTodo {
								TodoView(todo)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading your Todos", lucide: .squareCheckBig)
			}
		}.task {
			loadTodos()
		}.refreshable {
			await reloadTodos()
		}.navigationTitle("Todos")
	}
}

#Preview {
	NavigationStack {
		CurrentUserTodosLoader()
	}
}
