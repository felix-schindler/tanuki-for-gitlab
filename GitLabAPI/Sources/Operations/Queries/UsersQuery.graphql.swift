// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct UsersQuery: GraphQLQuery {
  public static let operationName: String = "Users"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Users($first: Int!, $after: String, $search: String, $admins: Boolean, $active: Boolean, $humans: Boolean) { users( search: $search admins: $admins active: $active humans: $humans first: $first after: $after ) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename avatarUrl name username } } }"#
    ))

  public var first: Int32
  public var after: GraphQLNullable<String>
  public var search: GraphQLNullable<String>
  public var admins: GraphQLNullable<Bool>
  public var active: GraphQLNullable<Bool>
  public var humans: GraphQLNullable<Bool>

  public init(
    first: Int32,
    after: GraphQLNullable<String>,
    search: GraphQLNullable<String>,
    admins: GraphQLNullable<Bool>,
    active: GraphQLNullable<Bool>,
    humans: GraphQLNullable<Bool>
  ) {
    self.first = first
    self.after = after
    self.search = search
    self.admins = admins
    self.active = active
    self.humans = humans
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "first": first,
    "after": after,
    "search": search,
    "admins": admins,
    "active": active,
    "humans": humans
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("users", Users?.self, arguments: [
        "search": .variable("search"),
        "admins": .variable("admins"),
        "active": .variable("active"),
        "humans": .variable("humans"),
        "first": .variable("first"),
        "after": .variable("after")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UsersQuery.Data.self
    ] }

    /// Find users.
    public var users: Users? { __data["users"] }

    /// Users
    ///
    /// Parent Type: `UserCoreConnection`
    nonisolated public struct Users: GitLabAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCoreConnection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node?]?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UsersQuery.Data.Users.self
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node?]? { __data["nodes"] }

      /// Users.PageInfo
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
          UsersQuery.Data.Users.PageInfo.self
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// Users.Node
      ///
      /// Parent Type: `UserCore`
      nonisolated public struct Node: GitLabAPI.SelectionSet {
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
          UsersQuery.Data.Users.Node.self
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
