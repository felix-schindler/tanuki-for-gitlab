// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct ProjectMergeRequestsQuery: GraphQLQuery {
  public static let operationName: String = "ProjectMergeRequests"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ProjectMergeRequests($fullPath: ID!, $state: MergeRequestState, $search: String, $draft: Boolean, $subscribed: SubscriptionStatus, $labels: [String], $milestone: String, $authorUsername: String, $assigneeUsername: String, $reviewerUsername: String, $createdAfter: Time, $createdBefore: Time, $updatedAfter: Time, $updatedBefore: Time) { project(fullPath: $fullPath) { __typename mergeRequestsEnabled mergeRequests( state: $state search: $search draft: $draft subscribed: $subscribed labelName: $labels milestoneTitle: $milestone authorUsername: $authorUsername assigneeUsername: $assigneeUsername reviewerUsername: $reviewerUsername createdAfter: $createdAfter createdBefore: $createdBefore updatedAfter: $updatedAfter updatedBefore: $updatedBefore ) { __typename nodes { __typename iid title reference(full: true) state upvotes downvotes userNotesCount author { __typename avatarUrl name username } createdAt webUrl } } } }"#
    ))

  public var fullPath: ID
  public var state: GraphQLNullable<GraphQLEnum<MergeRequestState>>
  public var search: GraphQLNullable<String>
  public var draft: GraphQLNullable<Bool>
  public var subscribed: GraphQLNullable<GraphQLEnum<SubscriptionStatus>>
  public var labels: GraphQLNullable<[String?]>
  public var milestone: GraphQLNullable<String>
  public var authorUsername: GraphQLNullable<String>
  public var assigneeUsername: GraphQLNullable<String>
  public var reviewerUsername: GraphQLNullable<String>
  public var createdAfter: GraphQLNullable<Time>
  public var createdBefore: GraphQLNullable<Time>
  public var updatedAfter: GraphQLNullable<Time>
  public var updatedBefore: GraphQLNullable<Time>

  public init(
    fullPath: ID,
    state: GraphQLNullable<GraphQLEnum<MergeRequestState>>,
    search: GraphQLNullable<String>,
    draft: GraphQLNullable<Bool>,
    subscribed: GraphQLNullable<GraphQLEnum<SubscriptionStatus>>,
    labels: GraphQLNullable<[String?]>,
    milestone: GraphQLNullable<String>,
    authorUsername: GraphQLNullable<String>,
    assigneeUsername: GraphQLNullable<String>,
    reviewerUsername: GraphQLNullable<String>,
    createdAfter: GraphQLNullable<Time>,
    createdBefore: GraphQLNullable<Time>,
    updatedAfter: GraphQLNullable<Time>,
    updatedBefore: GraphQLNullable<Time>
  ) {
    self.fullPath = fullPath
    self.state = state
    self.search = search
    self.draft = draft
    self.subscribed = subscribed
    self.labels = labels
    self.milestone = milestone
    self.authorUsername = authorUsername
    self.assigneeUsername = assigneeUsername
    self.reviewerUsername = reviewerUsername
    self.createdAfter = createdAfter
    self.createdBefore = createdBefore
    self.updatedAfter = updatedAfter
    self.updatedBefore = updatedBefore
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "fullPath": fullPath,
    "state": state,
    "search": search,
    "draft": draft,
    "subscribed": subscribed,
    "labels": labels,
    "milestone": milestone,
    "authorUsername": authorUsername,
    "assigneeUsername": assigneeUsername,
    "reviewerUsername": reviewerUsername,
    "createdAfter": createdAfter,
    "createdBefore": createdBefore,
    "updatedAfter": updatedAfter,
    "updatedBefore": updatedBefore
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["fullPath": .variable("fullPath")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ProjectMergeRequestsQuery.Data.self
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
        .field("mergeRequestsEnabled", Bool?.self),
        .field("mergeRequests", MergeRequests?.self, arguments: [
          "state": .variable("state"),
          "search": .variable("search"),
          "draft": .variable("draft"),
          "subscribed": .variable("subscribed"),
          "labelName": .variable("labels"),
          "milestoneTitle": .variable("milestone"),
          "authorUsername": .variable("authorUsername"),
          "assigneeUsername": .variable("assigneeUsername"),
          "reviewerUsername": .variable("reviewerUsername"),
          "createdAfter": .variable("createdAfter"),
          "createdBefore": .variable("createdBefore"),
          "updatedAfter": .variable("updatedAfter"),
          "updatedBefore": .variable("updatedBefore")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ProjectMergeRequestsQuery.Data.Project.self
      ] }

      /// Indicates if Merge requests are enabled for the current user
      public var mergeRequestsEnabled: Bool? { __data["mergeRequestsEnabled"] }
      /// Merge requests of the project.
      public var mergeRequests: MergeRequests? { __data["mergeRequests"] }

      /// Project.MergeRequests
      ///
      /// Parent Type: `MergeRequestConnection`
      nonisolated public struct MergeRequests: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequestConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProjectMergeRequestsQuery.Data.Project.MergeRequests.self
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Project.MergeRequests.Node
        ///
        /// Parent Type: `MergeRequest`
        nonisolated public struct Node: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequest }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("iid", String.self),
            .field("title", String.self),
            .field("reference", String.self, arguments: ["full": true]),
            .field("state", GraphQLEnum<GitLabAPI.MergeRequestState>.self),
            .field("upvotes", Int.self),
            .field("downvotes", Int.self),
            .field("userNotesCount", Int?.self),
            .field("author", Author?.self),
            .field("createdAt", GitLabAPI.Time.self),
            .field("webUrl", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProjectMergeRequestsQuery.Data.Project.MergeRequests.Node.self
          ] }

          /// Internal ID of the merge request.
          public var iid: String { __data["iid"] }
          /// Title of the merge request.
          public var title: String { __data["title"] }
          /// Internal reference of the merge request. Returned in shortened format by default.
          public var reference: String { __data["reference"] }
          /// State of the merge request.
          public var state: GraphQLEnum<GitLabAPI.MergeRequestState> { __data["state"] }
          /// Number of upvotes for the merge request.
          public var upvotes: Int { __data["upvotes"] }
          /// Number of downvotes for the merge request.
          public var downvotes: Int { __data["downvotes"] }
          /// User notes count of the merge request.
          public var userNotesCount: Int? { __data["userNotesCount"] }
          /// User who created the merge request.
          public var author: Author? { __data["author"] }
          /// Timestamp of when the merge request was created.
          public var createdAt: GitLabAPI.Time { __data["createdAt"] }
          /// Web URL of the merge request.
          public var webUrl: String? { __data["webUrl"] }

          /// Project.MergeRequests.Node.Author
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
              ProjectMergeRequestsQuery.Data.Project.MergeRequests.Node.Author.self
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
