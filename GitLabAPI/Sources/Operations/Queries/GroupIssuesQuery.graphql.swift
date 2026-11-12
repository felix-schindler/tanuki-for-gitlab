// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct GroupIssuesQuery: GraphQLQuery {
  public static let operationName: String = "GroupIssues"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GroupIssues($fullPath: ID!, $state: IssuableState, $search: String, $confidential: Boolean, $subscribed: SubscriptionStatus, $types: [IssueType!], $labels: [String], $milestones: [String], $authorUsername: String, $assigneeUsernames: [String!], $createdAfter: Time, $createdBefore: Time, $updatedAfter: Time, $updatedBefore: Time, $includeSubgroups: Boolean) { group(fullPath: $fullPath) { __typename issues( state: $state search: $search confidential: $confidential subscribed: $subscribed types: $types labelName: $labels milestoneTitle: $milestones authorUsername: $authorUsername assigneeUsernames: $assigneeUsernames createdAfter: $createdAfter createdBefore: $createdBefore updatedAfter: $updatedAfter updatedBefore: $updatedBefore includeSubgroups: $includeSubgroups ) { __typename nodes { __typename iid title reference(full: true) state upvotes downvotes userNotesCount author { __typename avatarUrl name username } createdAt webUrl } } } }"#
    ))

  public var fullPath: ID
  public var state: GraphQLNullable<GraphQLEnum<IssuableState>>
  public var search: GraphQLNullable<String>
  public var confidential: GraphQLNullable<Bool>
  public var subscribed: GraphQLNullable<GraphQLEnum<SubscriptionStatus>>
  public var types: GraphQLNullable<[GraphQLEnum<IssueType>]>
  public var labels: GraphQLNullable<[String?]>
  public var milestones: GraphQLNullable<[String?]>
  public var authorUsername: GraphQLNullable<String>
  public var assigneeUsernames: GraphQLNullable<[String]>
  public var createdAfter: GraphQLNullable<Time>
  public var createdBefore: GraphQLNullable<Time>
  public var updatedAfter: GraphQLNullable<Time>
  public var updatedBefore: GraphQLNullable<Time>
  public var includeSubgroups: GraphQLNullable<Bool>

  public init(
    fullPath: ID,
    state: GraphQLNullable<GraphQLEnum<IssuableState>>,
    search: GraphQLNullable<String>,
    confidential: GraphQLNullable<Bool>,
    subscribed: GraphQLNullable<GraphQLEnum<SubscriptionStatus>>,
    types: GraphQLNullable<[GraphQLEnum<IssueType>]>,
    labels: GraphQLNullable<[String?]>,
    milestones: GraphQLNullable<[String?]>,
    authorUsername: GraphQLNullable<String>,
    assigneeUsernames: GraphQLNullable<[String]>,
    createdAfter: GraphQLNullable<Time>,
    createdBefore: GraphQLNullable<Time>,
    updatedAfter: GraphQLNullable<Time>,
    updatedBefore: GraphQLNullable<Time>,
    includeSubgroups: GraphQLNullable<Bool>
  ) {
    self.fullPath = fullPath
    self.state = state
    self.search = search
    self.confidential = confidential
    self.subscribed = subscribed
    self.types = types
    self.labels = labels
    self.milestones = milestones
    self.authorUsername = authorUsername
    self.assigneeUsernames = assigneeUsernames
    self.createdAfter = createdAfter
    self.createdBefore = createdBefore
    self.updatedAfter = updatedAfter
    self.updatedBefore = updatedBefore
    self.includeSubgroups = includeSubgroups
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "fullPath": fullPath,
    "state": state,
    "search": search,
    "confidential": confidential,
    "subscribed": subscribed,
    "types": types,
    "labels": labels,
    "milestones": milestones,
    "authorUsername": authorUsername,
    "assigneeUsernames": assigneeUsernames,
    "createdAfter": createdAfter,
    "createdBefore": createdBefore,
    "updatedAfter": updatedAfter,
    "updatedBefore": updatedBefore,
    "includeSubgroups": includeSubgroups
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("group", Group?.self, arguments: ["fullPath": .variable("fullPath")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GroupIssuesQuery.Data.self
    ] }

    /// Find a group.
    public var group: Group? { __data["group"] }

    /// Group
    ///
    /// Parent Type: `Group`
    nonisolated public struct Group: GitLabAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Group }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("issues", Issues?.self, arguments: [
          "state": .variable("state"),
          "search": .variable("search"),
          "confidential": .variable("confidential"),
          "subscribed": .variable("subscribed"),
          "types": .variable("types"),
          "labelName": .variable("labels"),
          "milestoneTitle": .variable("milestones"),
          "authorUsername": .variable("authorUsername"),
          "assigneeUsernames": .variable("assigneeUsernames"),
          "createdAfter": .variable("createdAfter"),
          "createdBefore": .variable("createdBefore"),
          "updatedAfter": .variable("updatedAfter"),
          "updatedBefore": .variable("updatedBefore"),
          "includeSubgroups": .variable("includeSubgroups")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GroupIssuesQuery.Data.Group.self
      ] }

      /// Issues for projects in this group.
      public var issues: Issues? { __data["issues"] }

      /// Group.Issues
      ///
      /// Parent Type: `IssueConnection`
      nonisolated public struct Issues: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.IssueConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GroupIssuesQuery.Data.Group.Issues.self
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Group.Issues.Node
        ///
        /// Parent Type: `Issue`
        nonisolated public struct Node: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Issue }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("iid", String.self),
            .field("title", String.self),
            .field("reference", String.self, arguments: ["full": true]),
            .field("state", GraphQLEnum<GitLabAPI.IssueState>.self),
            .field("upvotes", Int.self),
            .field("downvotes", Int.self),
            .field("userNotesCount", Int.self),
            .field("author", Author.self),
            .field("createdAt", GitLabAPI.Time.self),
            .field("webUrl", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GroupIssuesQuery.Data.Group.Issues.Node.self
          ] }

          /// Internal ID of the issue.
          public var iid: String { __data["iid"] }
          /// Title of the issue.
          public var title: String { __data["title"] }
          /// Internal reference of the issue. Returned in shortened format by default.
          public var reference: String { __data["reference"] }
          /// State of the issue.
          public var state: GraphQLEnum<GitLabAPI.IssueState> { __data["state"] }
          /// Number of upvotes the issue has received.
          public var upvotes: Int { __data["upvotes"] }
          /// Number of downvotes the issue has received.
          public var downvotes: Int { __data["downvotes"] }
          /// Number of user notes of the issue.
          public var userNotesCount: Int { __data["userNotesCount"] }
          /// User that created the issue.
          public var author: Author { __data["author"] }
          /// Timestamp of when the issue was created.
          public var createdAt: GitLabAPI.Time { __data["createdAt"] }
          /// Web URL of the issue.
          public var webUrl: String { __data["webUrl"] }

          /// Group.Issues.Node.Author
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
              GroupIssuesQuery.Data.Group.Issues.Node.Author.self
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
