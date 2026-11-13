//
//  Icons.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

/// Central SF Symbol names, so entity icons are defined once instead of being
/// spelled out at every call site. Only symbols that carry a meaning within
/// Tanuki belong here; generic action glyphs (`checkmark`, `xmark`, `plus`, …)
/// stay inline.
enum Icons: String {
	// MARK: - Navigation
	case home = "house"
	case todos = "checkmark.square"
	case explore = "sparkles"
	case users = "person"
	case settings = "gear"

	// MARK: - Entities
	case issues = "smallcircle.circle"
	case projects = "app.gift.fill"
	case groups = "scale.3d"
	case snippets = "scissors"
	case flag = "flag"
	case milestones = "diamond"
	case tag = "tag"
	case members = "person.2"
	case events = "bell"
	case commits = "circle.and.line.horizontal"
	case comments = "note.text"

	// MARK: - Repository
	case code = "chevron.left.forwardslash.chevron.right"
	case files = "doc.text"
	case archive = "archivebox"
	case fork = "tuningfork"
	case star = "star"
	case timeTracking = "hourglass"
	case upvote = "hand.thumbsup"
	case downvote = "hand.thumbsdown"
	case copy = "doc.on.doc"
	case diffStats = "plusminus"
	case play = "play"

	// MARK: - Lists & actions
	case filter = "line.3.horizontal.decrease"
	case share = "square.and.arrow.up"
	case download = "square.and.arrow.down"
	case clock = "clock"

	// MARK: - Account
	case key = "key"
	case email = "envelope"
	case server = "server.rack"
	case cache = "internaldrive"
	case feedback = "exclamationmark.bubble"

	// MARK: - Visibility
	case lock = "lock"
	case globe = "globe"
	case shield = "shield.lefthalf.filled"
}

/// Bundled symbol images (`.symbols` assets) cannot be expressed with
/// `Icons`, because they are loaded by name instead of `systemName`.
enum Images: String {
	case mergeRequest = "git-mr.symbols"
	case mergeRequestClosed = "git-mr-closed.symbols"
	case mergeRequestMerged = "git-mr-merged.symbols"
	case cookie = "cookie.symbols"
}
