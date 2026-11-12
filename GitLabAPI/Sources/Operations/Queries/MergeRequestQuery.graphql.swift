// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct MergeRequestQuery: GraphQLQuery {
  public static let operationName: String = "MergeRequest"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MergeRequest($fullPath: ID!, $iid: String!) { project(fullPath: $fullPath) { __typename id avatarUrl mergeRequest(iid: $iid) { __typename iid title description reference(full: true) state sourceBranch targetBranch sourceProject { __typename fullPath } diffStatsSummary { __typename additions deletions fileCount } upvotes downvotes userNotesCount author { __typename avatarUrl name username } userPermissions { __typename canApprove canMerge updateMergeRequest createNote } createdAt webUrl approved mergeStatusEnum conflicts detailedMergeStatus rebaseInProgress assignees { __typename nodes { __typename avatarUrl username } } reviewers { __typename nodes { __typename avatarUrl username } } labels { __typename nodes { __typename title color textColor } } milestone { __typename iid title } humanTimeEstimate humanTotalTimeSpent notes { __typename nodes { __typename id author { __typename avatarUrl name username } maxAccessLevelOfAuthor body system systemNoteIconName createdAt updatedAt } } } } }"#
    ))

  public var fullPath: ID
  public var iid: String

  public init(
    fullPath: ID,
    iid: String
  ) {
    self.fullPath = fullPath
    self.iid = iid
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "fullPath": fullPath,
    "iid": iid
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["fullPath": .variable("fullPath")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MergeRequestQuery.Data.self
    ] }

    /// Find a project.
    public var project: Project? { __data["project"] }

    /// Project
    ///
    /// Parent Type: `Project`
    nonisolated public struct Project: GitLabAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Project }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GitLabAPI.ID.self),
        .field("avatarUrl", String?.self),
        .field("mergeRequest", MergeRequest?.self, arguments: ["iid": .variable("iid")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MergeRequestQuery.Data.Project.self
      ] }

      /// ID of the project.
      public var id: GitLabAPI.ID { __data["id"] }
      /// Avatar URL of the project.
      public var avatarUrl: String? { __data["avatarUrl"] }
      /// A single merge request of the project.
      public var mergeRequest: MergeRequest? { __data["mergeRequest"] }

      /// Project.MergeRequest
      ///
      /// Parent Type: `MergeRequest`
      nonisolated public struct MergeRequest: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequest }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("iid", String.self),
          .field("title", String.self),
          .field("description", String?.self),
          .field("reference", String.self, arguments: ["full": true]),
          .field("state", GraphQLEnum<GitLabAPI.MergeRequestState>.self),
          .field("sourceBranch", String.self),
          .field("targetBranch", String.self),
          .field("sourceProject", SourceProject?.self),
          .field("diffStatsSummary", DiffStatsSummary?.self),
          .field("upvotes", Int.self),
          .field("downvotes", Int.self),
          .field("userNotesCount", Int?.self),
          .field("author", Author?.self),
          .field("userPermissions", UserPermissions.self),
          .field("createdAt", GitLabAPI.Time.self),
          .field("webUrl", String?.self),
          .field("approved", Bool.self),
          .field("mergeStatusEnum", GraphQLEnum<GitLabAPI.MergeStatus>?.self),
          .field("conflicts", Bool.self),
          .field("detailedMergeStatus", GraphQLEnum<GitLabAPI.DetailedMergeStatus>?.self),
          .field("rebaseInProgress", Bool.self),
          .field("assignees", Assignees?.self),
          .field("reviewers", Reviewers?.self),
          .field("labels", Labels?.self),
          .field("milestone", Milestone?.self),
          .field("humanTimeEstimate", String?.self),
          .field("humanTotalTimeSpent", String?.self),
          .field("notes", Notes.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MergeRequestQuery.Data.Project.MergeRequest.self
        ] }

        /// Internal ID of the merge request.
        public var iid: String { __data["iid"] }
        /// Title of the merge request.
        public var title: String { __data["title"] }
        /// Description of the merge request (Markdown rendered as HTML for caching).
        public var description: String? { __data["description"] }
        /// Internal reference of the merge request. Returned in shortened format by default.
        public var reference: String { __data["reference"] }
        /// State of the merge request.
        public var state: GraphQLEnum<GitLabAPI.MergeRequestState> { __data["state"] }
        /// Source branch of the merge request.
        public var sourceBranch: String { __data["sourceBranch"] }
        /// Target branch of the merge request.
        public var targetBranch: String { __data["targetBranch"] }
        /// Source project of the merge request.
        public var sourceProject: SourceProject? { __data["sourceProject"] }
        /// Summary of which files were changed in the merge request.
        public var diffStatsSummary: DiffStatsSummary? { __data["diffStatsSummary"] }
        /// Number of upvotes for the merge request.
        public var upvotes: Int { __data["upvotes"] }
        /// Number of downvotes for the merge request.
        public var downvotes: Int { __data["downvotes"] }
        /// User notes count of the merge request.
        public var userNotesCount: Int? { __data["userNotesCount"] }
        /// User who created the merge request.
        public var author: Author? { __data["author"] }
        /// Permissions for the current user on the resource
        public var userPermissions: UserPermissions { __data["userPermissions"] }
        /// Timestamp of when the merge request was created.
        public var createdAt: GitLabAPI.Time { __data["createdAt"] }
        /// Web URL of the merge request.
        public var webUrl: String? { __data["webUrl"] }
        /// Indicates if the merge request has all the required approvals.
        public var approved: Bool { __data["approved"] }
        /// Merge status of the merge request.
        public var mergeStatusEnum: GraphQLEnum<GitLabAPI.MergeStatus>? { __data["mergeStatusEnum"] }
        /// Indicates if the merge request has conflicts.
        public var conflicts: Bool { __data["conflicts"] }
        /// Detailed merge status of the merge request.
        public var detailedMergeStatus: GraphQLEnum<GitLabAPI.DetailedMergeStatus>? { __data["detailedMergeStatus"] }
        /// Indicates if there is a rebase currently in progress for the merge request.
        public var rebaseInProgress: Bool { __data["rebaseInProgress"] }
        /// Assignees of the merge request.
        public var assignees: Assignees? { __data["assignees"] }
        /// Users from whom a review has been requested.
        public var reviewers: Reviewers? { __data["reviewers"] }
        /// Labels of the merge request.
        public var labels: Labels? { __data["labels"] }
        /// Milestone of the merge request.
        public var milestone: Milestone? { __data["milestone"] }
        /// Human-readable time estimate of the merge request.
        public var humanTimeEstimate: String? { __data["humanTimeEstimate"] }
        /// Human-readable total time reported as spent on the merge request.
        public var humanTotalTimeSpent: String? { __data["humanTotalTimeSpent"] }
        /// All notes on this noteable.
        public var notes: Notes { __data["notes"] }

        /// Project.MergeRequest.SourceProject
        ///
        /// Parent Type: `Project`
        nonisolated public struct SourceProject: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Project }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("fullPath", GitLabAPI.ID.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.SourceProject.self
          ] }

          /// Full path of the project.
          public var fullPath: GitLabAPI.ID { __data["fullPath"] }
        }

        /// Project.MergeRequest.DiffStatsSummary
        ///
        /// Parent Type: `DiffStatsSummary`
        nonisolated public struct DiffStatsSummary: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.DiffStatsSummary }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("additions", Int.self),
            .field("deletions", Int.self),
            .field("fileCount", Int.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.DiffStatsSummary.self
          ] }

          /// Number of lines added.
          public var additions: Int { __data["additions"] }
          /// Number of lines deleted.
          public var deletions: Int { __data["deletions"] }
          /// Number of files changed.
          public var fileCount: Int { __data["fileCount"] }
        }

        /// Project.MergeRequest.Author
        ///
        /// Parent Type: `MergeRequestAuthor`
        nonisolated public struct Author: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequestAuthor }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("avatarUrl", String?.self),
            .field("name", String.self),
            .field("username", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.Author.self
          ] }

          /// URL of the user's avatar.
          public var avatarUrl: String? { __data["avatarUrl"] }
          /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
          public var name: String { __data["name"] }
          /// Username of the user. Unique within the instance of GitLab.
          public var username: String { __data["username"] }
        }

        /// Project.MergeRequest.UserPermissions
        ///
        /// Parent Type: `MergeRequestPermissions`
        nonisolated public struct UserPermissions: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequestPermissions }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("canApprove", Bool.self),
            .field("canMerge", Bool.self),
            .field("updateMergeRequest", Bool.self),
            .field("createNote", Bool.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.UserPermissions.self
          ] }

          /// If `true`, the user can perform `can_approve` on this resource
          public var canApprove: Bool { __data["canApprove"] }
          /// If `true`, the user can perform `can_merge` on this resource
          public var canMerge: Bool { __data["canMerge"] }
          /// If `true`, the user can perform `update_merge_request` on this resource
          public var updateMergeRequest: Bool { __data["updateMergeRequest"] }
          /// If `true`, the user can perform `create_note` on this resource
          public var createNote: Bool { __data["createNote"] }
        }

        /// Project.MergeRequest.Assignees
        ///
        /// Parent Type: `MergeRequestAssigneeConnection`
        nonisolated public struct Assignees: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequestAssigneeConnection }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.Assignees.self
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }

          /// Project.MergeRequest.Assignees.Node
          ///
          /// Parent Type: `MergeRequestAssignee`
          nonisolated public struct Node: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequestAssignee }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("avatarUrl", String?.self),
              .field("username", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MergeRequestQuery.Data.Project.MergeRequest.Assignees.Node.self
            ] }

            /// URL of the user's avatar.
            public var avatarUrl: String? { __data["avatarUrl"] }
            /// Username of the user. Unique within the instance of GitLab.
            public var username: String { __data["username"] }
          }
        }

        /// Project.MergeRequest.Reviewers
        ///
        /// Parent Type: `MergeRequestReviewerConnection`
        nonisolated public struct Reviewers: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequestReviewerConnection }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.Reviewers.self
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }

          /// Project.MergeRequest.Reviewers.Node
          ///
          /// Parent Type: `MergeRequestReviewer`
          nonisolated public struct Node: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequestReviewer }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("avatarUrl", String?.self),
              .field("username", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MergeRequestQuery.Data.Project.MergeRequest.Reviewers.Node.self
            ] }

            /// URL of the user's avatar.
            public var avatarUrl: String? { __data["avatarUrl"] }
            /// Username of the user. Unique within the instance of GitLab.
            public var username: String { __data["username"] }
          }
        }

        /// Project.MergeRequest.Labels
        ///
        /// Parent Type: `LabelConnection`
        nonisolated public struct Labels: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.LabelConnection }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.Labels.self
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }

          /// Project.MergeRequest.Labels.Node
          ///
          /// Parent Type: `Label`
          nonisolated public struct Node: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Label }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("title", String.self),
              .field("color", String.self),
              .field("textColor", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MergeRequestQuery.Data.Project.MergeRequest.Labels.Node.self
            ] }

            /// Content of the label.
            public var title: String { __data["title"] }
            /// Background color of the label.
            public var color: String { __data["color"] }
            /// Text color of the label.
            public var textColor: String { __data["textColor"] }
          }
        }

        /// Project.MergeRequest.Milestone
        ///
        /// Parent Type: `Milestone`
        nonisolated public struct Milestone: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Milestone }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("iid", GitLabAPI.ID.self),
            .field("title", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.Milestone.self
          ] }

          /// Internal ID of the milestone.
          public var iid: GitLabAPI.ID { __data["iid"] }
          /// Title of the milestone.
          public var title: String { __data["title"] }
        }

        /// Project.MergeRequest.Notes
        ///
        /// Parent Type: `NoteConnection`
        nonisolated public struct Notes: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.NoteConnection }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MergeRequestQuery.Data.Project.MergeRequest.Notes.self
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }

          /// Project.MergeRequest.Notes.Node
          ///
          /// Parent Type: `Note`
          nonisolated public struct Node: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Note }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", GitLabAPI.NoteID.self),
              .field("author", Author?.self),
              .field("maxAccessLevelOfAuthor", String?.self),
              .field("body", String.self),
              .field("system", Bool.self),
              .field("systemNoteIconName", String?.self),
              .field("createdAt", GitLabAPI.Time.self),
              .field("updatedAt", GitLabAPI.Time.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MergeRequestQuery.Data.Project.MergeRequest.Notes.Node.self
            ] }

            /// ID of the note.
            public var id: GitLabAPI.NoteID { __data["id"] }
            /// User who wrote the note.
            public var author: Author? { __data["author"] }
            /// Max access level of the note author in the project.
            public var maxAccessLevelOfAuthor: String? { __data["maxAccessLevelOfAuthor"] }
            /// Content of the note.
            public var body: String { __data["body"] }
            /// Indicates whether the note was created by the system or by a user.
            public var system: Bool { __data["system"] }
            /// Name of the icon corresponding to a system note.
            public var systemNoteIconName: String? { __data["systemNoteIconName"] }
            /// Timestamp of the note creation.
            public var createdAt: GitLabAPI.Time { __data["createdAt"] }
            /// Timestamp of the note's last activity.
            public var updatedAt: GitLabAPI.Time { __data["updatedAt"] }

            /// Project.MergeRequest.Notes.Node.Author
            ///
            /// Parent Type: `UserCore`
            nonisolated public struct Author: GitLabAPI.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCore }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("avatarUrl", String?.self),
                .field("name", String.self),
                .field("username", String.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                MergeRequestQuery.Data.Project.MergeRequest.Notes.Node.Author.self
              ] }

              /// URL of the user's avatar.
              public var avatarUrl: String? { __data["avatarUrl"] }
              /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
              public var name: String { __data["name"] }
              /// Username of the user. Unique within the instance of GitLab.
              public var username: String { __data["username"] }
            }
          }
        }
      }
    }
  }
}
