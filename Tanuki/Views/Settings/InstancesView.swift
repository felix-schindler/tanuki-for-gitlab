//
//  InstancesView.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.04.26.
//

import SwiftUI

struct InstancesView: View {
	@State
	private var instances: [GitLabInstance] = InstanceManager.instances
	@State
	private var selectedId: String? = InstanceManager.selectedId
	@State
	private var instanceToDelete: GitLabInstance?

	private func delete(_ instance: GitLabInstance) {
		let wasSelected = instance.id == InstanceManager.selectedId
		InstanceManager.remove(instance)
		instances = InstanceManager.instances
		selectedId = InstanceManager.selectedId
		if wasSelected {
			Task {
				if let next = InstanceManager.selected {
					await Auth.switchInstance(to: next)
				} else {
					await Auth.logout()
				}
			}
		}
	}

	var body: some View {
		List {
			if instances.isEmpty {
				NoContentView(
					"No Instances",
					systemImage: Icons.server.rawValue,
					description: "Add a GitLab instance to get started"
				)
			} else {
				Section {
					ForEach(instances) { instance in
						HStack {
							VStack(alignment: .leading) {
								Text(instance.host)
									.font(.headline)
								Text(instance.isOAuth ? "GitLab.com (OAuth)" : "Self-Hosted")
									.font(.caption)
									.foregroundStyle(.secondary)
							}

							Spacer()

							if instance.id == selectedId {
								Image(systemName: "checkmark.circle.fill")
									.foregroundStyle(.accent)
							}
						}
						.contentShape(.rect)
						.onTapGesture {
							Task {
								await Auth.switchInstance(to: instance)
								instances = InstanceManager.instances
								selectedId = InstanceManager.selectedId
							}
						}
						.swipeActions(edge: .trailing) {
							Button(role: .destructive) {
								instanceToDelete = instance
							} label: {
								Label("Delete", systemImage: "trash").labelStyle(.iconOnly)
							}
						}
					}
				} header: {
					Text("Instances")
				}
			}

			Section {
				NavigationLink(destination: AddInstanceView()) {
					Label("Add Instance", systemImage: "plus.circle")
				}
			}
		}.onAppear {
			instances = InstanceManager.instances
			selectedId = InstanceManager.selectedId
		}.confirmationDialog(
			"Delete \(instanceToDelete?.host ?? "instance")?",
			isPresented: Binding(
				get: { instanceToDelete != nil },
				set: { if !$0 { instanceToDelete = nil } }
			),
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				if let instance = instanceToDelete {
					delete(instance)
				}
				instanceToDelete = nil
			}
			Button("Cancel", role: .cancel) {
				instanceToDelete = nil
			}
		} message: {
			Text(
				"The account and its token will be removed from this device. You'll need to sign in again to add it back."
			)
		}.toolbar {
			NavigationLink(destination: AddInstanceView()) {
				Label("Add Instance", systemImage: "plus")
			}
		}.navigationTitle("Instances")
	}
}

#Preview {
	NavigationStack {
		InstancesView()
	}
}
