//
//  UserView.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct UserView: View {
	private let user: User
	private let isSelf: Bool

	init(_ user: User, isSelf: Bool) {
		self.user = user
		self.isSelf = isSelf
	}

	public var body: some View {
		VStack(alignment: .leading) {
			HStack {
				if let avatarUrl = URL.fromAvatar(user.avatarUrl) {
					AvatarImage(avatarUrl, size: .medium)
				}
				VStack(alignment: .leading, spacing: 0) {
					ScrollView(.horizontal) {
						HStack {
							if user.bot {
								Text("🤖")
							}
							Text(user.name)
								.fontWeight(.bold)
							if let pronouns = user.pronouns, pronouns.isNotEmpty {
								PillView(pronouns)
							}
						}
					}
					Text("@\(user.username)")
						.foregroundStyle(.secondary)
				}

				if let createdAt = user.createdAt {
					Spacer()
					Text(Date.fromToString(createdAt))
						.font(.footnote)
				}
			}

			let location = user.location
			let hasJob = user.jobTitle?.isNotEmpty ?? false
			let hasOrg = user.organization?.isNotEmpty ?? false

			if hasJob || hasOrg || (location?.isNotEmpty ?? false) {
				ScrollView(.horizontal) {
					HStack {
						if let location, location.isNotEmpty {
							if let url = URL(
								string:
									"https://maps.apple.com/?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
							) {
								Link(
									destination: url,
									label: {
										PillView(
											location,
											icon: .mapPin,
											bgColor: .accentColor,
											fgColor: .white
										)
									}
								)
							} else {
								PillView(location, icon: .mapPin)
							}
						}

						if hasJob || hasOrg {
							let workInfo =
								hasJob && hasOrg
								? "\(user.jobTitle!) at \(user.organization!)"
								: "\(user.jobTitle ?? "") \(user.organization ?? "")"
									.trimmingCharacters(in: .whitespaces)
							PillView(workInfo, icon: .briefcase)
						}
					}.font(.footnote)
				}
			}

			if let bio = user.bio, bio.isNotEmpty {
				Markdown(bio)
			}
		}

		if user.state != .active {
			Section {
				switch user.state {
				case .blocked:
					Text(
						"User has been blocked by an administrator and cannot use the system."
					)
				case .deactivated:
					Text("User is no longer active and cannot use the system.")
				case .banned:
					Text("User is blocked, and their contributions are hidden.")
				case .ldapBlocked:
					Text("User has been blocked by the system.")
				case .blockedPendingApproval:
					Text("User is blocked and pending approval.")
				default:
					Text("Unknown user state.")
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.font(.footnote)
			.padding(.horizontal, 8)
			.padding(.vertical, 6)
			.background(.orange)
			.cornerRadius(5)
		}

		if let status = user._status {
			Section {
				NavigationLink(
					destination: UpdateStatusView(),
					label: {
						HStack {
							if let emoji = status.emoji {
								Text(":\(emoji):".emojized())
							}
							if let message = status.message?.emojized(), message.isNotEmpty {
								Text(message)
							}
						}
					}
				).disabled(!self.isSelf)
			}
		} else if isSelf {
			Section {
				NavigationLink(
					destination: UpdateStatusView(),
					label: {
						Label("Create status", lucide: .pencil)
					})
			}
		}

		let showMail = user.publicEmail?.isNotEmpty ?? false
		let showIn = user.linkedin?.isNotEmpty ?? false
		let showTwitter = user.twitter?.isNotEmpty ?? false
		let showDiscord = user.discord?.isNotEmpty ?? false

		if showMail || showIn || showTwitter || showDiscord {
			Section("Contact") {
				if showMail {
					let mailLink = "mailto:\(user.publicEmail!)"
					if let mailUrl = URL(string: mailLink) {
						Link(user.publicEmail!, destination: mailUrl)
					} else {
						Text(user.publicEmail!)
							.textSelection(.enabled)
					}
				}

				if showIn {
					let inLink = "https://www.linkedin.com/in/\(user.linkedin!)"
					if let inUrl = URL(string: inLink) {
						Link("LinkedIn / \(user.linkedin!)", destination: inUrl)
					} else {
						Text(inLink)
							.textSelection(.enabled)
					}
				}

				if showTwitter {
					let xLink = "https://twitter.com/\(user.twitter!)"
					if let xUrl = URL(string: xLink) {
						Link("𝕏 / \(user.twitter!)", destination: xUrl)
					} else {
						Text(xLink)
							.textSelection(.enabled)
					}
				}

				if showDiscord {
					let discordLink = "https://discord.gg/\(user.discord!)"
					if let discordUrl = URL(string: discordLink) {
						Link("Discord / \(user.discord!)", destination: discordUrl)
					} else {
						Text(discordLink)
							.textSelection(.enabled)
					}
				}
			}
		}

		Section("Contributions") {
			ContributionsLoader(username: user.username)
		}

		Section {
			NavigationLink(
				destination: UserIssuesLoader(username: user.username),
				label: {
					Label("Issues", lucide: .circleDot, color: .green)
				}
			)
			NavigationLink(
				destination: UserGroupsLoader(user.username),
				label: {
					Label(
						title: {
							HStack {
								Text("Groups")
								Spacer()
								Text(String(user.groupCount ?? 0))
							}
						},
						icon: {
							LucideLabelIcon(.building, color: .red)
						}
					)
				})
			NavigationLink(
				destination: UserProjectsLoader(username: user.username),
				label: {
					Label("Projects", lucide: .layers, color: .gray)
				})
			NavigationLink(
				destination: UserStarredProjectsLoader(username: user.username),
				label: {
					Label("Starred projects", lucide: .star, color: .yellow)
				})
			NavigationLink(
				destination: UserSnippetsLoader(username: user.username),
				label: {
					Label("Snippets", lucide: .scissors, color: .purple)
				})
			if let id = user.id.toIntId() {
				NavigationLink(
					destination: EventsLoader(userId: id),
					label: {
						Label("Activity", lucide: .activity)
					}
				)
			}
			NavigationLink(
				destination: TimelogsLoader(
					fullPath: user.username,
					queryType: .user
				),
				label: {
					Label("Timelogs", lucide: .hourglass)
				}
			)
			NavigationLink(
				destination: UserTodosLoader(username: user.username),
				label: {
					Label("Todos", lucide: .squareCheckBig)
				}
			)
		}
	}
}
