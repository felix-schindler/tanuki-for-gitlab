//
//  TypeHelper.swift
//  Tanuki
//
//  Created by Felix Schindler on 28.02.24.
//

import Foundation
import GitLabAPI

// MARK: - Global
protocol HasAuthor {
	var _author: MyAuthor { get }
}

protocol MaybeHasAuthor {
	var _author: MyAuthor? { get }
}

struct MyAuthor: Codable, Author {
	let avatarUrl: String?
	let name: String
	let username: String
}

// MARK: - USERS
protocol Author {
	var avatarUrl: String? { get }
	var name: String { get }
	var username: String { get }
}

protocol Member {
	var id: String { get }
	var createdAt: String? { get }
	var expiresAt: String? { get }
	var _accessLevel: String? { get }
	var _user: MyAuthor? { get }
	var _createdBy: MyAuthor? { get }
}

extension UsersQuery.Data.Users.Node: Author {
}

extension ProjectMembersQuery.Data.Project.ProjectMembers.Node: Member {
	var _accessLevel: String? {
		return accessLevel?.stringValue?.rawValue
	}

	var _user: MyAuthor? {
		guard let userData = user else { return nil }
		return MyAuthor(
			avatarUrl: userData.avatarUrl,
			name: userData.name,
			username: userData.username
		)
	}

	var _createdBy: MyAuthor? {
		guard let authorData = createdBy else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

extension GroupMembersQuery.Data.Group.GroupMembers.Node: Member {
	var _accessLevel: String? {
		return accessLevel?.stringValue?.rawValue
	}

	var _user: MyAuthor? {
		guard let userData = user else { return nil }
		return MyAuthor(
			avatarUrl: userData.avatarUrl,
			name: userData.name,
			username: userData.username
		)
	}

	var _createdBy: MyAuthor? {
		guard let authorData = createdBy else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}

}

// MARK: - MERGE REQUESTS
struct ProjectPath {
	var fullPath: String
}

protocol SmallMergeRequest {
	var iid: String { get }
	var title: String { get }
	var reference: String { get }
	var state: GraphQLEnum<GitLabAPI.MergeRequestState> { get }
	var upvotes: Int { get }
	var downvotes: Int { get }
	var userNotesCount: Int? { get }
	var _author: MyAuthor? { get }
	var createdAt: String { get }
	var webUrl: String? { get }
}

protocol MergeRequest {
	var _author: MyAuthor? { get }
}

extension MergeRequestQuery.Data.Project.MergeRequest: MergeRequest {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

extension ProjectMergeRequestsQuery.Data.Project.MergeRequests.Node:
	SmallMergeRequest
{
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

extension GroupMergeRequestsQuery.Data.Group.MergeRequests.Node: SmallMergeRequest {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

protocol UserSmallMergeRequest: SmallMergeRequest {
	var _project: ProjectPath { get }
}

extension UserAssignedMergeRequestsQuery.Data.CurrentUser.AssignedMergeRequests
	.Node: UserSmallMergeRequest
{
	var _project: ProjectPath {
		return ProjectPath(fullPath: project.fullPath)
	}

	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl, name: authorData.name,
			username: authorData.username)
	}
}
extension UserAuthoredMergeRequestsQuery.Data.CurrentUser.AuthoredMergeRequests
	.Node: UserSmallMergeRequest
{
	var _project: ProjectPath {
		return ProjectPath(fullPath: project.fullPath)
	}

	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}
extension UserReviewRequestedMergeRequestsQuery.Data.CurrentUser
	.ReviewRequestedMergeRequests.Node: UserSmallMergeRequest
{
	var _project: ProjectPath {
		return ProjectPath(fullPath: project.fullPath)
	}

	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

// MARK: - NOTES
protocol Note {
	var system: Bool { get }
	var systemNoteIconName: String? { get }
	var body: String { get }
	var _author: MyAuthor? { get }
	var createdAt: String { get }
	var updatedAt: String { get }
	var maxAccessLevelOfAuthor: String? { get }
}

extension IssueQuery.Data.Project.Issue.Notes.Node: Note {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

extension MergeRequestQuery.Data.Project.MergeRequest.Notes.Node: Note {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

extension SnippetQuery.Data.Snippets.Node.Notes.Node: Note {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

// MARK: - Issues
protocol SmallIssue {
	var iid: String { get }
	var title: String { get }
	var reference: String { get }
	var state: GraphQLEnum<GitLabAPI.IssueState> { get }
	var upvotes: Int { get }
	var downvotes: Int { get }
	var userNotesCount: Int { get }
	var _author: MyAuthor { get }
	var createdAt: String { get }
	var webUrl: String { get }
}

extension IssueQuery.Data.Project.Issue: HasAuthor {
	var _author: MyAuthor {
		return MyAuthor(
			avatarUrl: author.avatarUrl,
			name: author.name,
			username: author.username
		)
	}
}

extension ProjectIssuesQuery.Data.Project.Issues.Node: SmallIssue {
	var _author: MyAuthor {
		return MyAuthor(
			avatarUrl: author.avatarUrl,
			name: author.name,
			username: author.username
		)
	}
}

extension GroupIssuesQuery.Data.Group.Issues.Node: SmallIssue {
	var _author: MyAuthor {
		return MyAuthor(
			avatarUrl: author.avatarUrl,
			name: author.name,
			username: author.username
		)
	}
}

protocol IssueProjectMembership {
	var fullPath: String? { get }
	var _issues: [SmallIssue?]? { get }
}

extension UserIssuesQuery.Data.User.ProjectMemberships.Node: IssueProjectMembership {
	var fullPath: String? {
		return project?.fullPath
	}

	var _issues: [SmallIssue?]? {
		return project?.issues?.nodes
	}
}

extension CurrentUserIssuesQuery.Data.CurrentUser.ProjectMemberships.Node: IssueProjectMembership {
	var fullPath: String? {
		return project?.fullPath
	}

	var _issues: [SmallIssue?]? {
		return project?.issues?.nodes
	}
}

extension UserIssuesQuery.Data.User.ProjectMemberships.Node.Project.Issues.Node: SmallIssue {
	var _author: MyAuthor {
		return MyAuthor(avatarUrl: author.avatarUrl, name: author.name, username: author.username)
	}
}

extension CurrentUserIssuesQuery.Data.CurrentUser.ProjectMemberships.Node.Project.Issues.Node:
	SmallIssue
{
	var _author: MyAuthor {
		return MyAuthor(avatarUrl: author.avatarUrl, name: author.name, username: author.username)
	}
}

// MARK: - PROJECTS
protocol SmallProject {
	var avatarUrl: String? { get }
	var nameWithNamespace: String { get }
	var visibility: String? { get }
	var fullPath: String { get }
	var archived: Bool? { get }
}

struct SmallProjectStruct: SmallProject {
	let avatarUrl: String?
	let nameWithNamespace: String
	let visibility: String?
	let fullPath: String
	let archived: Bool?
}

extension ProjectsQuery.Data.Projects.Node: SmallProject {
}

extension CurrentUserStarredProjectsQuery.Data.CurrentUser.StarredProjects.Node: SmallProject {
}

extension UserStarredProjectsQuery.Data.User.StarredProjects.Node: SmallProject {
}

extension GroupProjectsQuery.Data.Group.Projects.Node: SmallProject {
}

extension UserMembershipProjectsQuery.Data.User.ProjectMemberships.Node.Project: SmallProject {
}

// MARK: - Users
struct UserStatus {
	let emoji: String?
	let message: String?
}

protocol User {
	var id: String { get }
	var avatarUrl: String? { get }
	var name: String { get }
	var username: String { get }
	var bot: Bool { get }
	var pronouns: String? { get }
	var state: GraphQLEnum<GitLabAPI.UserState> { get }
	var _status: UserStatus? { get }
	var bio: String? { get }
	var location: String? { get }
	var jobTitle: String? { get }
	var organization: String? { get }
	var discord: String? { get }
	var twitter: String? { get }
	var linkedin: String? { get }
	var publicEmail: String? { get }
	var groupCount: Int? { get }
	var createdAt: String? { get }
	var webUrl: String { get }
}

extension CurrentUserQuery.Data.CurrentUser: User {
	var _status: UserStatus? {
		guard let statusData = status else { return nil }
		return UserStatus(emoji: statusData.emoji, message: statusData.message)
	}
}

extension UserQuery.Data.User: User {
	var _status: UserStatus? {
		guard let statusData = status else { return nil }
		return UserStatus(emoji: statusData.emoji, message: statusData.message)
	}
}

// MARK: - Snippets
protocol Snippet {
	var id: String { get }
	var title: String { get }
	var _author: MyAuthor? { get }
	var createdAt: String { get }
	var webUrl: String { get }
	var visibilityLevel: GraphQLEnum<GitLabAPI.VisibilityLevelsEnum> { get }
}

extension SnippetQuery.Data.Snippets.Node: Snippet {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

extension CurrentUserSnippetsQuery.Data.CurrentUser.Snippets.Node: Snippet {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

extension UserSnippetsQuery.Data.User.Snippets.Node: Snippet {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

// MARK: - Groups
protocol Group {
	var avatarUrl: String? { get }
	var _name: String? { get }
	var fullPath: String { get }
	var visibility: String? { get }
	var groupMembersCount: Int { get }
	var projectsCount: Int { get }
	var _accessLevel: String? { get }
}

extension GroupsQuery.Data.Groups.Node: Group {
	var _name: String? {
		return self.name
	}

	var _accessLevel: String? {
		return self.maxAccessLevel.stringValue?.rawValue
	}
}

extension UserGroupsQuery.Data.User.Groups.Node: Group {
	var _name: String? {
		return self.name
	}

	var _accessLevel: String? {
		return self.maxAccessLevel.stringValue?.rawValue
	}
}

// MARK: - RELEASES
protocol Release {
	var _author: MyAuthor? { get }
}

extension ProjectReleasesQuery.Data.Project.Releases.Node: Release {
	var _author: MyAuthor? {
		guard let authorData = author else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

// MARK: - Labels
protocol MyLabel {
	var id: String { get }
	var title: String { get }
	var description: String? { get }
	var color: String { get }
	var textColor: String { get }
}

extension GroupLabelsQuery.Data.Group.Labels.Node: MyLabel {
}

extension ProjectLabelsQuery.Data.Project.Labels.Node: MyLabel {
}

// MARK: - Timelogs
struct T_Project {
	let fullPath: String
	let nameWithNamespace: String
}

struct T_Issue {
	let iid: String
}

struct T_MR {
	let iid: String
}

protocol Timelog {
	var id: String { get }
	var _user: MyAuthor { get }
	var spentAt: String? { get }
	var summary: String? { get }
	var timeSpent: Int { get }
	var _project: T_Project { get }
	var _issue: T_Issue? { get }
	var _mergeRequest: T_MR? { get }
}

extension GroupTimelogsQuery.Data.Group.Timelogs.Node: Timelog {
	var _user: MyAuthor {
		MyAuthor(avatarUrl: user.avatarUrl, name: user.name, username: user.username)
	}

	var _project: T_Project {
		T_Project(fullPath: project.fullPath, nameWithNamespace: project.nameWithNamespace)
	}

	var _issue: T_Issue? {
		guard let issueData = issue else { return nil }
		return T_Issue(iid: issueData.iid)
	}

	var _mergeRequest: T_MR? {
		guard let mrData = mergeRequest else { return nil }
		return T_MR(iid: mrData.iid)
	}
}

extension UserTimelogsQuery.Data.User.Timelogs.Node: Timelog {
	var _user: MyAuthor {
		MyAuthor(avatarUrl: user.avatarUrl, name: user.name, username: user.username)
	}

	var _project: T_Project {
		T_Project(fullPath: project.fullPath, nameWithNamespace: project.nameWithNamespace)
	}

	var _issue: T_Issue? {
		guard let issueData = issue else { return nil }
		return T_Issue(iid: issueData.iid)
	}

	var _mergeRequest: T_MR? {
		guard let mrData = mergeRequest else { return nil }
		return T_MR(iid: mrData.iid)
	}
}

// MARK: - Pipelines
extension ProjectPipelinesQuery.Data.Project.Pipelines.Node: MaybeHasAuthor {
	var _author: MyAuthor? {
		guard let authorData = user else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

extension PipelineDetailQuery.Data.Project.Pipeline: MaybeHasAuthor {
	var _author: MyAuthor? {
		guard let authorData = user else { return nil }
		return MyAuthor(
			avatarUrl: authorData.avatarUrl,
			name: authorData.name,
			username: authorData.username
		)
	}
}

// MARK: - Milestones
struct MyStats {
	let closedIssuesCount: Int?
	let totalIssuesCount: Int?
}

protocol Milestone {
	var iid: GitLabAPI.ID { get }
	var state: GraphQLEnum<GitLabAPI.MilestoneStateEnum> { get }
	var title: String { get }
	var description: String? { get }
	var expired: Bool { get }
	var startDate: String? { get }
	var dueDate: String? { get }
	var _stats: MyStats? { get }
	var webPath: String { get }
}

extension GroupMilestonesQuery.Data.Group.Milestones.Node: Milestone {
	var _stats: MyStats? {
		guard let statsData = stats else { return nil }
		return MyStats(
			closedIssuesCount: statsData.closedIssuesCount,
			totalIssuesCount: statsData.totalIssuesCount
		)
	}
}

extension ProjectMilestonesQuery.Data.Project.Milestones.Node: Milestone {
	var _stats: MyStats? {
		guard let statsData = stats else { return nil }
		return MyStats(
			closedIssuesCount: statsData.closedIssuesCount,
			totalIssuesCount: statsData.totalIssuesCount
		)
	}
}

// MARK: - Todos
protocol Todo {
	var id: String { get }
	var body: String { get }
	var _groupPath: String? { get }
	var state: GraphQLEnum<GitLabAPI.TodoStateEnum> { get }
	var action: GraphQLEnum<GitLabAPI.TodoActionEnum> { get }
	var _author: MyAuthor { get }
	var _webUrl: String? { get }
	var _project: SmallProject? { get }
	var createdAt: GitLabAPI.Time { get }
	var targetType: GraphQLEnum<GitLabAPI.TodoTargetEnum> { get }
}

extension UserTodosQuery.Data.User.Todos.Node: Todo {
	var _project: SmallProject? {
		guard let projectData = project else { return nil }
		return SmallProjectStruct(
			avatarUrl: projectData.avatarUrl,
			nameWithNamespace: projectData.nameWithNamespace,
			visibility: projectData.visibility,
			fullPath: projectData.fullPath,
			archived: projectData.archived
		)
	}

	var _groupPath: String? {
		return group?.id
	}

	var _author: MyAuthor {
		return MyAuthor(
			avatarUrl: author.avatarUrl,
			name: author.name,
			username: author.username
		)
	}

	var _webUrl: String? {
		return targetEntity?.webUrl
	}
}

extension CurrentUserTodosQuery.Data.CurrentUser.Todos.Node: Todo {
	var _project: SmallProject? {
		guard let projectData = project else { return nil }
		return SmallProjectStruct(
			avatarUrl: projectData.avatarUrl,
			nameWithNamespace: projectData.nameWithNamespace,
			visibility: projectData.visibility,
			fullPath: projectData.fullPath,
			archived: projectData.archived
		)
	}

	var _groupPath: String? {
		return group?.id
	}

	var _author: MyAuthor {
		return MyAuthor(
			avatarUrl: author.avatarUrl,
			name: author.name,
			username: author.username
		)
	}

	var _webUrl: String? {
		return targetEntity?.webUrl
	}
}

// MARK: - Commits
protocol NewCommit {
	var id: String { get }
	var title: String? { get }
	var shortId: String { get }
	var authorName: String? { get }
	var authoredDate: GitLabAPI.Time? { get }
	var webUrl: String { get }
	var _signatureVerificationStatus: String? { get }
	var _lastPipelineStatus: GraphQLEnum<GitLabAPI.PipelineStatusEnum>? { get }
}

extension ProjectQuery.Data.Project.Repository.Tree.LastCommit: NewCommit {
	var _signatureVerificationStatus: String? {
		return self.signature?.verificationStatus?.rawValue
	}

	var _lastPipelineStatus: ApolloAPI.GraphQLEnum<GitLabAPI.PipelineStatusEnum>? {
		if let pipelines = pipelines?.nodes, pipelines.isNotEmpty {
			return pipelines[0]?.status
		} else {
			return nil
		}
	}
}

extension MergeRequestCommitsQuery.Data.Project.MergeRequest.Commits.Node: NewCommit {
	var _signatureVerificationStatus: String? {
		return self.signature?.verificationStatus?.rawValue
	}

	var _lastPipelineStatus: ApolloAPI.GraphQLEnum<GitLabAPI.PipelineStatusEnum>? {
		if let pipelines = pipelines?.nodes, pipelines.isNotEmpty {
			return pipelines[0]?.status
		} else {
			return nil
		}
	}
}
