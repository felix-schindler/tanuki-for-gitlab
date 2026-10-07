//
//  JumpURL.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.09.26.
//

import Foundation

enum JumpTarget: Hashable {
	/// A bare `host/namespace/path` — a project, group or user, resolved at runtime.
	case entity(fullPath: String)
	/// A single issue / merge request: the project path and iid are right there in the URL.
	case issue(fullPath: String, iid: String)
	case mergeRequest(fullPath: String, iid: String)
	/// Any `/-/…` sub-page of a project or group, resolved at runtime.
	case route(fullPath: String, route: JumpRoute)
}

enum JumpRoute: Hashable {
	case issues
	case mergeRequests
	case releases(tag: String?)
	case pipelines
	case labels
	case milestones
	case members
	case activity
	case branches
	case tags
	case commits(ref: String?)
	case commit(sha: String)
	case tree(ref: String?, path: String?)
	case blob(ref: String?, path: String)
}

extension JumpTarget {
	var describeTarget: String {
		switch self {
		case .entity(let fullPath):
			return "“\(fullPath)”"
		case .issue(let fullPath, let iid):
			return "Project “\(fullPath)” → issue ##\(iid)"
		case .mergeRequest(let fullPath, let iid):
			return "Project “\(fullPath)” → merge request !\(iid)"
		case .route(let fullPath, let route):
			return "“\(fullPath)” → \(route.describeTarget)"
		}
	}
}

extension JumpRoute {
	var describeTarget: String {
		switch self {
		case .issues:
			return "issues"
		case .mergeRequests:
			return "merge requests"
		case .releases(let tag):
			return tag.map { "release “\($0)”" } ?? "releases"
		case .pipelines:
			return "pipelines"
		case .labels:
			return "labels"
		case .milestones:
			return "milestones"
		case .members:
			return "members"
		case .activity:
			return "activity"
		case .branches:
			return "branches"
		case .tags:
			return "tags"
		case .commits(let ref):
			return ref.map { "commits on “\($0)”" } ?? "commits"
		case .commit(let sha):
			return "commit \(sha)"
		case .tree(let ref, _):
			return ref.map { "repository at “\($0)”" } ?? "repository"
		case .blob(_, let path):
			return "file “\(path)”"
		}
	}
}

enum JumpURLError: Error, Equatable {
	case emptyClipboard
	case notALink(raw: String)
	case wrongHost(urlHost: String, expectedHost: String)
	case nothingToOpen(raw: String, host: String)

	var title: String {
		switch self {
		case .emptyClipboard, .notALink:
			return "No link on the clipboard"
		case .wrongHost:
			return "That link belongs to another instance"
		case .nothingToOpen:
			return "That link doesn't point anywhere"
		}
	}

	var message: String {
		switch self {
		case .emptyClipboard:
			return "Nothing was on the clipboard. Copy a GitLab link, then try again."
		case .notALink(let raw):
			return
				"“\(JumpURLError.excerpt(raw))” isn't an http(s) link, so there's nothing to open."
		case .wrongHost(let urlHost, let expectedHost):
			return
				"The link is for “\(urlHost)”, but this app is signed in to “\(expectedHost)”, so it can't open it."
		case .nothingToOpen(_, let host):
			return "The link only points at “\(host)”, not at a project, group, issue or merge request."
		}
	}

	var hint: String? {
		switch self {
		case .emptyClipboard:
			return nil
		case .notALink:
			return "A GitLab link looks like https://gitlab.com/group/project"
		case .wrongHost(_, let expectedHost):
			return "Open the link in a browser, or sign in to \(expectedHost) in Settings."
		case .nothingToOpen(_, let host):
			return "Pick a project, issue or merge request on \(host) and copy that link instead."
		}
	}

	static func excerpt(_ raw: String, limit: Int = 160) -> String {
		let collapsed = raw.split(whereSeparator: \.isWhitespace).joined(separator: " ")
		guard collapsed.isNotEmpty else { return "(empty)" }
		guard collapsed.count > limit else { return collapsed }
		return String(collapsed.prefix(limit)) + "…"
	}
}

enum JumpURL {
	private static let separator = "-"

	static func parse(_ raw: String, host: String) throws -> JumpTarget {
		let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
		guard trimmed.isNotEmpty else { throw JumpURLError.emptyClipboard }

		let candidate = firstURL(in: trimmed) ?? trimmed

		guard let url = URL(string: candidate),
			let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
			let urlHost = hostWithPort(of: url)
		else { throw JumpURLError.notALink(raw: trimmed) }

		guard isSameHost(urlHost, host) else {
			throw JumpURLError.wrongHost(urlHost: urlHost, expectedHost: host)
		}

		let segments = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
		guard !segments.isEmpty else {
			throw JumpURLError.nothingToOpen(raw: trimmed, host: host)
		}

		// No `/-/`: a project, group or user path.
		guard let separatorIndex = segments.firstIndex(of: separator) else {
			return .entity(fullPath: segments.joined(separator: "/"))
		}

		let fullPath = segments[..<separatorIndex].joined(separator: "/")
		guard fullPath.isNotEmpty else {
			throw JumpURLError.nothingToOpen(raw: trimmed, host: host)
		}

		let rest = Array(segments[segments.index(after: separatorIndex)...])
		guard let kind = rest.first else {
			return .entity(fullPath: fullPath)
		}
		let value = rest.count >= 2 ? rest[1] : nil
		let tail = rest.count > 2 ? rest[2...].joined(separator: "/") : nil

		switch kind {
		case "issues", "work_items":
			if let value { return .issue(fullPath: fullPath, iid: value) }
			return .route(fullPath: fullPath, route: .issues)
		case "merge_requests":
			if let value { return .mergeRequest(fullPath: fullPath, iid: value) }
			return .route(fullPath: fullPath, route: .mergeRequests)
		case "releases":
			return .route(fullPath: fullPath, route: .releases(tag: value))
		case "pipelines":
			return .route(fullPath: fullPath, route: .pipelines)
		case "labels":
			return .route(fullPath: fullPath, route: .labels)
		case "milestones":
			return .route(fullPath: fullPath, route: .milestones)
		case "project_members", "group_members", "members":
			return .route(fullPath: fullPath, route: .members)
		case "activity":
			return .route(fullPath: fullPath, route: .activity)
		case "branches":
			return .route(fullPath: fullPath, route: .branches)
		case "tags":
			return .route(fullPath: fullPath, route: .tags)
		case "commits":
			return .route(fullPath: fullPath, route: .commits(ref: value))
		case "commit":
			guard let sha = value else { return .entity(fullPath: fullPath) }
			return .route(fullPath: fullPath, route: .commit(sha: sha))
		case "tree":
			return .route(fullPath: fullPath, route: .tree(ref: value, path: tail))
		case "blob":
			guard let path = tail else { return .entity(fullPath: fullPath) }
			return .route(fullPath: fullPath, route: .blob(ref: value, path: path))
		default:
			return .entity(fullPath: fullPath)
		}
	}

	/// Extracts the first `http(s)://…` token from text that may hold more than a link.
	private static func firstURL(in text: String) -> String? {
		let lowercased = text.lowercased()
		guard let start = ["https://", "http://"].compactMap({ lowercased.range(of: $0)?.lowerBound }).min()
		else { return nil }

		let terminators: Set<Character> = [" ", "\n", "\r", "\t", "<", ">", "\"", "'", "`", "]", ")", ","]
		let tail = text[start...]
		let end = tail.firstIndex(where: { terminators.contains($0) }) ?? text.endIndex
		return String(text[start..<end])
	}

	/// `host`, plus the port when it isn't the default one. `URL.host()` drops it,
	/// but a self-hosted instance may live on a port.
	private static func hostWithPort(of url: URL) -> String? {
		guard let host = url.host()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
			host.isNotEmpty
		else { return nil }
		guard let port = url.port, port != 443, port != 80 else { return host }
		return "\(host):\(port)"
	}

	private static func isSameHost(_ urlHost: String, _ expectedHost: String) -> Bool {
		func name(_ host: String) -> String {
			let bare = stripPort(host)
			return bare.hasPrefix("www.") ? String(bare.dropFirst(4)) : bare
		}

		let expected = expectedHost.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		guard name(urlHost) == name(expected) else { return false }

		// `hostWithPort()` already drops default ports, so a nil URL port means default;
		// treat an explicit default port on the configured host the same way.
		let urlPort = port(of: urlHost)
		let expectedPort = port(of: expected).flatMap { $0 == "443" || $0 == "80" ? nil : $0 }
		return urlPort == expectedPort
	}

	private static func stripPort(_ host: String) -> String {
		guard let colon = host.lastIndex(of: ":") else { return host }
		return String(host[..<colon])
	}

	private static func port(of host: String) -> String? {
		guard let colon = host.lastIndex(of: ":") else { return nil }
		return String(host[host.index(after: colon)...])
	}
}

/// Everything the app knows about the last "Jump" attempt, so the UI can say
/// which link was on the clipboard and why it didn't open.
struct JumpDiagnostics {
	let raw: String
	let host: String
	var target: JumpTarget?
	var error: JumpURLError?

	var summary: String {
		error?.title ?? target?.describeTarget ?? "Nothing to open"
	}

	/// Multi-line, copyable report — this is what belongs in a bug report.
	var report: String {
		var lines = [
			"Tanuki: could not open link from clipboard",
			"Signed-in instance: \(host)",
			"Clipboard: \(JumpURLError.excerpt(raw))",
		]

		if let error {
			lines.append("Reason: \(error.message)")
			if let hint = error.hint {
				lines.append("Hint: \(hint)")
			}
		}

		if let target {
			lines.append("Target: \(target.describeTarget)")
		}

		return lines.joined(separator: "\n")
	}
}
