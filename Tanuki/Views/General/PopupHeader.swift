//
//  PopupHeader.swift
//  Tanuki
//
//  Created by Felix Schindler on 04.03.24.
//

import SwiftUI

struct PopupHeader: View {
	public let title: String
	public let onClose: () -> Void

	public var body: some View {
		HStack {
			Text(title)
				.font(.title)
				.fontWeight(.bold)
			Spacer()
			CloseButton {
				onClose()
			}
		}
	}
}

#Preview {
	NavigationStack {
	}.sheet(isPresented: .constant(true)) {
		VStack {
			PopupHeader(title: "Test", onClose: {})
			Spacer()
			Button(
				action: {},
				label: {
					Label("Test", lucide: .check)
						.frame(maxWidth: .infinity)
				}
			)
			.tint(.green)
			.adaptiveButtonStyle()
			.controlSize(.large)
		}
		.padding()
	}
}
