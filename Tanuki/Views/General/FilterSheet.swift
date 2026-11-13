//
//  FilterSheet.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import SwiftUI

struct FilterSheet<Filters: Equatable, Content: View>: View {
	@Binding var filters: Filters
	let initialValue: Filters
	@Environment(\.dismiss) private var dismiss
	@ViewBuilder let content: () -> Content

	var body: some View {
		NavigationStack {
			Form {
				content()
			}
			.scrollDismissesKeyboard(.immediately)
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Filters")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Reset") {
						filters = initialValue
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Done", systemImage: "checkmark") {
						dismiss()
					}
				}
			}
		}
	}
}

/// A date filter that only applies while its toggle is on.
struct OptionalDatePicker: View {
	private let title: String
	@Binding private var date: Foundation.Date?

	init(_ title: String, date: Binding<Foundation.Date?>) {
		self.title = title
		self._date = date
	}

	var body: some View {
		Toggle(
			title,
			isOn: Binding(
				get: { date != nil },
				set: { isOn in
					date = isOn ? (date ?? Foundation.Date()) : nil
				}
			)
		)

		if let current = date {
			DatePicker(
				title,
				selection: Binding(
					get: { current },
					set: { date = $0 }
				),
				displayedComponents: [.date]
			)
		}
	}
}

#Preview {
	FilterSheet(filters: .constant(IssueFilter()), initialValue: IssueFilter()) {
		Section("Dates") {
			OptionalDatePicker("Created after", date: .constant(nil))
		}
	}
}
