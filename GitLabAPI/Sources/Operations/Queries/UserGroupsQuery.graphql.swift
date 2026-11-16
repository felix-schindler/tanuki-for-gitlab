// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct UserGroupsQuery: GraphQLQuery {
  public static let operationName: String = "UserGroups"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query UserGroups($first: Int!, $after: String, $username: String!) { user(username: $username) { __typename groups(first: $first, after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename avatarUrl name fullPath visibility groupMembersCount projectsCount maxAccessLevel { __typename stringValue } } } } }"#
    ))

  public var first: Int32
  public var after: GraphQLNullable<String>
  public var username: String

  public init(
    first: Int32,
    after: GraphQLNullable<String>,
    username: String
  ) {
    self.first = first
    self.after = after
    self.username = username
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "first": first,
    "after": after,
    "username": username
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("user", User?.self, arguments: ["username": .variable("username")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UserGroupsQuery.Data.self
    ] }

    /// Find a user.
    public var user: User? { __data["user"] }

    /// User
    ///
    /// Parent Type: `UserCore`
    nonisolated public struct User: GitLabAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCore }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("groups", Groups?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UserGroupsQuery.Data.User.self
      ] }

      /// Groups where the user has access.
      public var groups: Groups? { __data["groups"] }

      /// User.Groups
      ///
      /// Parent Type: `GroupConnection`
      nonisolated public struct Groups: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.GroupConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node?]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UserGroupsQuery.Data.User.Groups.self
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// User.Groups.PageInfo
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
            UserGroupsQuery.Data.User.Groups.PageInfo.self
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// User.Groups.Node
        ///
        /// Parent Type: `Group`
        nonisolated public struct Node: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Group }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("avatarUrl", String?.self),
            .field("name", String?.self),
            .field("fullPath", GitLabAPI.ID.self),
            .field("visibility", String?.self),
            .field("groupMembersCount", Int.self),
            .field("projectsCount", Int.self),
            .field("maxAccessLevel", MaxAccessLevel.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            UserGroupsQuery.Data.User.Groups.Node.self
          ] }

          /// Avatar URL of the group.
          public var avatarUrl: String? { __data["avatarUrl"] }
          /// Name of the group.
          public var name: String? { __data["name"] }
          /// Full path of the namespace.
          public var fullPath: GitLabAPI.ID { __data["fullPath"] }
          /// Visibility of the namespace.
          public var visibility: String? { __data["visibility"] }
          /// Count of direct members of the group.
          public var groupMembersCount: Int { __data["groupMembersCount"] }
          /// Count of direct projects in the group.
          public var projectsCount: Int { __data["projectsCount"] }
          /// Maximum access level of the current user in the group.
          public var maxAccessLevel: MaxAccessLevel { __data["maxAccessLevel"] }

          /// User.Groups.Node.MaxAccessLevel
          ///
          /// Parent Type: `AccessLevel`
          nonisolated public struct MaxAccessLevel: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.AccessLevel }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("stringValue", GraphQLEnum<GitLabAPI.AccessLevelEnum>?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              UserGroupsQuery.Data.User.Groups.Node.MaxAccessLevel.self
            ] }

            /// Enum string of the the access level.
            public var stringValue: GraphQLEnum<GitLabAPI.AccessLevelEnum>? { __data["stringValue"] }
          }
        }
      }
    }
  }
}
