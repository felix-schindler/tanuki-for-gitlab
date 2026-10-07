// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

nonisolated public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GitLabAPI.SchemaMetadata {}

nonisolated public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GitLabAPI.SchemaMetadata {}

nonisolated public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GitLabAPI.SchemaMetadata {}

nonisolated public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GitLabAPI.SchemaMetadata {}

nonisolated public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  private static let objectTypeMap: [String: ApolloAPI.Object] = [
    "AbuseReportDiscussion": GitLabAPI.Objects.AbuseReportDiscussion,
    "AbuseReportLabel": GitLabAPI.Objects.AbuseReportLabel,
    "AbuseReportNote": GitLabAPI.Objects.AbuseReportNote,
    "AccessLevel": GitLabAPI.Objects.AccessLevel,
    "AlertManagementAlert": GitLabAPI.Objects.AlertManagementAlert,
    "AutocompletedUser": GitLabAPI.Objects.AutocompletedUser,
    "Blob": GitLabAPI.Objects.Blob,
    "BlobConnection": GitLabAPI.Objects.BlobConnection,
    "Commit": GitLabAPI.Objects.Commit,
    "CommitConnection": GitLabAPI.Objects.CommitConnection,
    "CurrentUser": GitLabAPI.Objects.CurrentUser,
    "CustomEmoji": GitLabAPI.Objects.CustomEmoji,
    "CustomEmojiConnection": GitLabAPI.Objects.CustomEmojiConnection,
    "Design": GitLabAPI.Objects.Design,
    "DesignAtVersion": GitLabAPI.Objects.DesignAtVersion,
    "DiffStats": GitLabAPI.Objects.DiffStats,
    "DiffStatsSummary": GitLabAPI.Objects.DiffStatsSummary,
    "Discussion": GitLabAPI.Objects.Discussion,
    "GpgSignature": GitLabAPI.Objects.GpgSignature,
    "Group": GitLabAPI.Objects.Group,
    "GroupConnection": GitLabAPI.Objects.GroupConnection,
    "GroupMember": GitLabAPI.Objects.GroupMember,
    "GroupMemberConnection": GitLabAPI.Objects.GroupMemberConnection,
    "GroupPermissions": GitLabAPI.Objects.GroupPermissions,
    "Issue": GitLabAPI.Objects.Issue,
    "IssueConnection": GitLabAPI.Objects.IssueConnection,
    "IssuePermissions": GitLabAPI.Objects.IssuePermissions,
    "Key": GitLabAPI.Objects.Key,
    "Label": GitLabAPI.Objects.Label,
    "LabelConnection": GitLabAPI.Objects.LabelConnection,
    "MemberInterfaceConnection": GitLabAPI.Objects.MemberInterfaceConnection,
    "MergeRequest": GitLabAPI.Objects.MergeRequest,
    "MergeRequestAssignee": GitLabAPI.Objects.MergeRequestAssignee,
    "MergeRequestAssigneeConnection": GitLabAPI.Objects.MergeRequestAssigneeConnection,
    "MergeRequestAuthor": GitLabAPI.Objects.MergeRequestAuthor,
    "MergeRequestConnection": GitLabAPI.Objects.MergeRequestConnection,
    "MergeRequestParticipant": GitLabAPI.Objects.MergeRequestParticipant,
    "MergeRequestPermissions": GitLabAPI.Objects.MergeRequestPermissions,
    "MergeRequestReviewer": GitLabAPI.Objects.MergeRequestReviewer,
    "MergeRequestReviewerConnection": GitLabAPI.Objects.MergeRequestReviewerConnection,
    "Milestone": GitLabAPI.Objects.Milestone,
    "MilestoneConnection": GitLabAPI.Objects.MilestoneConnection,
    "MilestoneStats": GitLabAPI.Objects.MilestoneStats,
    "Mutation": GitLabAPI.Objects.Mutation,
    "Namespace": GitLabAPI.Objects.Namespace,
    "Note": GitLabAPI.Objects.Note,
    "NoteConnection": GitLabAPI.Objects.NoteConnection,
    "Pipeline": GitLabAPI.Objects.Pipeline,
    "PipelineConnection": GitLabAPI.Objects.PipelineConnection,
    "Project": GitLabAPI.Objects.Project,
    "ProjectConnection": GitLabAPI.Objects.ProjectConnection,
    "ProjectMember": GitLabAPI.Objects.ProjectMember,
    "ProjectMemberConnection": GitLabAPI.Objects.ProjectMemberConnection,
    "ProjectPermissions": GitLabAPI.Objects.ProjectPermissions,
    "ProjectStatistics": GitLabAPI.Objects.ProjectStatistics,
    "Query": GitLabAPI.Objects.Query,
    "Release": GitLabAPI.Objects.Release,
    "ReleaseAssetLink": GitLabAPI.Objects.ReleaseAssetLink,
    "ReleaseAssetLinkConnection": GitLabAPI.Objects.ReleaseAssetLinkConnection,
    "ReleaseAssets": GitLabAPI.Objects.ReleaseAssets,
    "ReleaseConnection": GitLabAPI.Objects.ReleaseConnection,
    "ReleaseSource": GitLabAPI.Objects.ReleaseSource,
    "ReleaseSourceConnection": GitLabAPI.Objects.ReleaseSourceConnection,
    "Repository": GitLabAPI.Objects.Repository,
    "RepositoryBlob": GitLabAPI.Objects.RepositoryBlob,
    "RepositoryBlobConnection": GitLabAPI.Objects.RepositoryBlobConnection,
    "RepositoryLanguage": GitLabAPI.Objects.RepositoryLanguage,
    "Snippet": GitLabAPI.Objects.Snippet,
    "SnippetBlob": GitLabAPI.Objects.SnippetBlob,
    "SnippetBlobConnection": GitLabAPI.Objects.SnippetBlobConnection,
    "SnippetConnection": GitLabAPI.Objects.SnippetConnection,
    "SnippetPermissions": GitLabAPI.Objects.SnippetPermissions,
    "SshSignature": GitLabAPI.Objects.SshSignature,
    "StarProjectPayload": GitLabAPI.Objects.StarProjectPayload,
    "Submodule": GitLabAPI.Objects.Submodule,
    "Timelog": GitLabAPI.Objects.Timelog,
    "TimelogConnection": GitLabAPI.Objects.TimelogConnection,
    "Todo": GitLabAPI.Objects.Todo,
    "TodoConnection": GitLabAPI.Objects.TodoConnection,
    "Tree": GitLabAPI.Objects.Tree,
    "TreeEntry": GitLabAPI.Objects.TreeEntry,
    "TreeEntryConnection": GitLabAPI.Objects.TreeEntryConnection,
    "UpdateIssuePayload": GitLabAPI.Objects.UpdateIssuePayload,
    "UserCore": GitLabAPI.Objects.UserCore,
    "UserCoreConnection": GitLabAPI.Objects.UserCoreConnection,
    "UserStatus": GitLabAPI.Objects.UserStatus,
    "WikiPage": GitLabAPI.Objects.WikiPage,
    "WorkItem": GitLabAPI.Objects.WorkItem,
    "WorkItemWidgetAssignees": GitLabAPI.Objects.WorkItemWidgetAssignees,
    "WorkItemWidgetAwardEmoji": GitLabAPI.Objects.WorkItemWidgetAwardEmoji,
    "WorkItemWidgetCrmContacts": GitLabAPI.Objects.WorkItemWidgetCrmContacts,
    "WorkItemWidgetCurrentUserTodos": GitLabAPI.Objects.WorkItemWidgetCurrentUserTodos,
    "WorkItemWidgetDescription": GitLabAPI.Objects.WorkItemWidgetDescription,
    "WorkItemWidgetDesigns": GitLabAPI.Objects.WorkItemWidgetDesigns,
    "WorkItemWidgetDevelopment": GitLabAPI.Objects.WorkItemWidgetDevelopment,
    "WorkItemWidgetEmailParticipants": GitLabAPI.Objects.WorkItemWidgetEmailParticipants,
    "WorkItemWidgetErrorTracking": GitLabAPI.Objects.WorkItemWidgetErrorTracking,
    "WorkItemWidgetHierarchy": GitLabAPI.Objects.WorkItemWidgetHierarchy,
    "WorkItemWidgetLabels": GitLabAPI.Objects.WorkItemWidgetLabels,
    "WorkItemWidgetLinkedItems": GitLabAPI.Objects.WorkItemWidgetLinkedItems,
    "WorkItemWidgetLinkedResources": GitLabAPI.Objects.WorkItemWidgetLinkedResources,
    "WorkItemWidgetMilestone": GitLabAPI.Objects.WorkItemWidgetMilestone,
    "WorkItemWidgetNotes": GitLabAPI.Objects.WorkItemWidgetNotes,
    "WorkItemWidgetNotifications": GitLabAPI.Objects.WorkItemWidgetNotifications,
    "WorkItemWidgetParticipants": GitLabAPI.Objects.WorkItemWidgetParticipants,
    "WorkItemWidgetStartAndDueDate": GitLabAPI.Objects.WorkItemWidgetStartAndDueDate,
    "WorkItemWidgetTimeTracking": GitLabAPI.Objects.WorkItemWidgetTimeTracking,
    "X509Signature": GitLabAPI.Objects.X509Signature
  ]

  @_spi(Execution) public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    objectTypeMap[typename]
  }
}

nonisolated public enum Objects {}
nonisolated public enum Interfaces {}
nonisolated public enum Unions {}
