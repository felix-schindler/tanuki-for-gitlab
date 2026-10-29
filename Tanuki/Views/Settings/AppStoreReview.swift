//
//  AppStoreReview.swift
//  Tanuki
//
//  Created by Felix Schindler on 18.02.26.
//

import StoreKit
import SwiftUI

struct AppStoreReview: View {
	@Environment(\.requestReview) var requestReview

	public var body: some View {
		Button("App Store Review", systemImage: "star") {
			requestReview()
		}
	}
}

#Preview {
	AppStoreReview()
}
