// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct GroupTimelogsQuery: GraphQLQuery {
  public static let operationName: String = "GroupTimelogs"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GroupTimelogs($first: Int!, $after: String, $fullPath: ID!) { group(fullPath: $fullPath) { __typename timelogs(sort: SPENT_AT_DESC, first: $first, after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename id user { __typename avatarUrl name username } spentAt summary timeSpent project { __typename fullPath nameWithNamespace } issue { __typename iid } mergeRequest { __typename iid } } } } }"#
    ))

  public var first: Int32
  public var after: GraphQLNullable<String>
  public var fullPath: ID

  public init(
    first: Int32,
    after: GraphQLNullable<String>,
    fullPath: ID
  ) {
    self.first = first
    self.after = after
    self.fullPath = fullPath
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "first": first,
    "after": after,
    "fullPath": fullPath
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("group", Group?.self, arguments: ["fullPath": .variable("fullPath")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GroupTimelogsQuery.Data.self
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
        .field("timelogs", Timelogs.self, arguments: [
          "sort": "SPENT_AT_DESC",
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GroupTimelogsQuery.Data.Group.self
      ] }

      /// Time logged on issues and merge requests in the group and its subgroups.
      public var timelogs: Timelogs { __data["timelogs"] }

      /// Group.Timelogs
      ///
      /// Parent Type: `TimelogConnection`
      nonisolated public struct Timelogs: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.TimelogConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node?]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GroupTimelogsQuery.Data.Group.Timelogs.self
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Group.Timelogs.PageInfo
        ///
        /// Parent Type: `PageInfo`
        nonisolated public struct PageInfo: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.PageInfo }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GroupTimelogsQuery.Data.Group.Timelogs.PageInfo.self
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// Group.Timelogs.Node
        ///
        /// Parent Type: `Timelog`
        nonisolated public struct Node: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Timelog }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GitLabAPI.ID.self),
            .field("user", User.self),
            .field("spentAt", GitLabAPI.Time?.self),
            .field("summary", String?.self),
            .field("timeSpent", Int.self),
            .field("project", Project.self),
            .field("issue", Issue?.self),
            .field("mergeRequest", MergeRequest?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GroupTimelogsQuery.Data.Group.Timelogs.Node.self
          ] }

          /// Internal ID of the timelog.
          public var id: GitLabAPI.ID { __data["id"] }
          /// User that logged the time.
          public var user: User { __data["user"] }
          /// Timestamp of when the time tracked was spent at.
          public var spentAt: GitLabAPI.Time? { __data["spentAt"] }
          /// Summary of how the time was spent.
          public var summary: String? { __data["summary"] }
          /// Time spent displayed in seconds.
          public var timeSpent: Int { __data["timeSpent"] }
          /// Target project of the timelog merge request or issue.
          public var project: Project { __data["project"] }
          /// Issue that logged time was added to.
          public var issue: Issue? { __data["issue"] }
          /// Merge request that logged time was added to.
          public var mergeRequest: MergeRequest? { __data["mergeRequest"] }

          /// Group.Timelogs.Node.User
          ///
          /// Parent Type: `UserCore`
          nonisolated public struct User: GitLabAPI.SelectionSet {
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
              GroupTimelogsQuery.Data.Group.Timelogs.Node.User.self
            ] }

            /// URL of the user's avatar.
            public var avatarUrl: String? { __data["avatarUrl"] }
            /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
            public var name: String { __data["name"] }
            /// Username of the user. Unique within the instance of GitLab.
            public var username: String { __data["username"] }
          }

          /// Group.Timelogs.Node.Project
          ///
          /// Parent Type: `Project`
          nonisolated public struct Project: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Project }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("fullPath", GitLabAPI.ID.self),
              .field("nameWithNamespace", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GroupTimelogsQuery.Data.Group.Timelogs.Node.Project.self
            ] }

            /// Full path of the project.
            public var fullPath: GitLabAPI.ID { __data["fullPath"] }
            /// Name of the project including the namespace.
            public var nameWithNamespace: String { __data["nameWithNamespace"] }
          }

          /// Group.Timelogs.Node.Issue
          ///
          /// Parent Type: `Issue`
          nonisolated public struct Issue: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Issue }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("iid", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GroupTimelogsQuery.Data.Group.Timelogs.Node.Issue.self
            ] }

            /// Internal ID of the issue.
            public var iid: String { __data["iid"] }
          }

          /// Group.Timelogs.Node.MergeRequest
          ///
          /// Parent Type: `MergeRequest`
          nonisolated public struct MergeRequest: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequest }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("iid", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GroupTimelogsQuery.Data.Group.Timelogs.Node.MergeRequest.self
            ] }

            /// Internal ID of the merge request.
            public var iid: String { __data["iid"] }
          }
        }
      }
    }
  }
}
