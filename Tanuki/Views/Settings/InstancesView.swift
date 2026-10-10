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

	var body: some View {
		List {
			if instances.isEmpty {
				NoContentView(
					"No Instances",
					lucide: .server,
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
								LucideLabelIcon(.circleCheck)
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
							} label: {
								Label("Delete", lucide: .trash).labelStyle(.iconOnly)
							}
						}
					}
				} header: {
					Text("Instances")
				}
			}

			Section {
				NavigationLink(destination: ConfigView(showSetup: nil)) {
					Label("Add Instance", lucide: .circlePlus)
				}
			}
		}.task {
			instances = InstanceManager.instances
			selectedId = InstanceManager.selectedId
		}.toolbar {
			NavigationLink(destination: ConfigView(showSetup: nil)) {
				Label("Add Instance", lucide: .plus)
			}
		}.navigationTitle("Instances")
	}
}

#Preview {
	NavigationStack {
		InstancesView()
	}
}
