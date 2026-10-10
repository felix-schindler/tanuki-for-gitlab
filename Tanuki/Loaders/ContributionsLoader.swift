//
//  ContributionsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 09.04.24.
//

import Charts
import SwiftUI

struct ContributionsLoader: View {
	private let username: String
	private let height: CGFloat = 50

	/// User contributions in format ["YYYY-MM-DD" → intCount]
	@State
	private var contributions: Result<[String: Int], Error>? = nil

	init(username: String) {
		self.username = username
	}

	private func loadContributions() async {
		do {
			var temp = try await API.get(
				type: [String: Int].self,
				endpoint: "users/\(username)/calendar.json",
				useBase: false
			)

			if let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) {
				let endDate = Date()
				var currentDate = startDate
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd"

				while currentDate <= endDate {
					let dateString = dateFormatter.string(from: currentDate)
					if temp[dateString] == nil {
						temp[dateString] = 0
					}
					currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
				}
			}

			contributions = .success(temp)
		} catch let error {
			contributions = .failure(error)
		}
	}

	var body: some View {
		VStack {
			if let contributions {
				switch contributions {
				case .success(let contributions):
					if contributions.filter({ $0.value > 0 }).isEmpty {
						Text("\(self.username) has no contributions within the last year")
					} else {
						Chart {
							ForEach(contributions.sorted(by: { $0.key < $1.key }), id: \.key) {
								key, value in
								BarMark(
									x: .value("Date", key),
									y: .value("Contributions", value)
								)
							}
						}
						.chartYAxis {
							AxisMarks(values: .automatic(desiredCount: 3))
						}
						.chartXAxis(.hidden)
						.frame(height: self.height)
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Contributions", lucide: .calendar)
			}
		}.task {
			await loadContributions()
		}.refreshable {
			await loadContributions()
		}.frame(maxWidth: .infinity, minHeight: self.height)
	}
}

#Preview {
	List {
		ContributionsLoader(username: "felix-schindler")
	}
}
