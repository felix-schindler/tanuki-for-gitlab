//
//  TrailingIconLabelStyle.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import SwiftUI

/// Lays a label out as title then icon, so metadata icons line up at the
/// trailing edge of a row instead of leading the text.
struct TrailingIconLabelStyle: LabelStyle {
	var useSpacer: Bool = true

	func makeBody(configuration: LabelStyleConfiguration) -> some View {
		HStack {
			configuration.title
				.multilineTextAlignment(.leading)
			if useSpacer {
				Spacer()
			}
			configuration.icon
		}
	}
}
