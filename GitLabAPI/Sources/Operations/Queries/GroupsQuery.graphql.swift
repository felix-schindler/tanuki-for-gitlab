// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct GroupsQuery: GraphQLQuery {
  public static let operationName: String = "Groups"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Groups($first: Int!, $after: String, $topLevelOnly: Boolean, $ownedOnly: Boolean, $search: String, $parentPath: ID, $allAvailable: Boolean, $markedForDeletionOn: Date, $active: Boolean) { groups( first: $first after: $after topLevelOnly: $topLevelOnly ownedOnly: $ownedOnly search: $search parentPath: $parentPath allAvailable: $allAvailable markedForDeletionOn: $markedForDeletionOn active: $active ) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename avatarUrl name fullPath visibility maxAccessLevel { __typename stringValue } } } }"#
    ))

  public var first: Int32
  public var after: GraphQLNullable<String>
  public var topLevelOnly: GraphQLNullable<Bool>
  public var ownedOnly: GraphQLNullable<Bool>
  public var search: GraphQLNullable<String>
  public var parentPath: GraphQLNullable<ID>
  public var allAvailable: GraphQLNullable<Bool>
  public var markedForDeletionOn: GraphQLNullable<Date>
  public var active: GraphQLNullable<Bool>

  public init(
    first: Int32,
    after: GraphQLNullable<String>,
    topLevelOnly: GraphQLNullable<Bool>,
    ownedOnly: GraphQLNullable<Bool>,
    search: GraphQLNullable<String>,
    parentPath: GraphQLNullable<ID>,
    allAvailable: GraphQLNullable<Bool>,
    markedForDeletionOn: GraphQLNullable<Date>,
    active: GraphQLNullable<Bool>
  ) {
    self.first = first
    self.after = after
    self.topLevelOnly = topLevelOnly
    self.ownedOnly = ownedOnly
    self.search = search
    self.parentPath = parentPath
    self.allAvailable = allAvailable
    self.markedForDeletionOn = markedForDeletionOn
    self.active = active
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "first": first,
    "after": after,
    "topLevelOnly": topLevelOnly,
    "ownedOnly": ownedOnly,
    "search": search,
    "parentPath": parentPath,
    "allAvailable": allAvailable,
    "markedForDeletionOn": markedForDeletionOn,
    "active": active
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("groups", Groups?.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after"),
        "topLevelOnly": .variable("topLevelOnly"),
        "ownedOnly": .variable("ownedOnly"),
        "search": .variable("search"),
        "parentPath": .variable("parentPath"),
        "allAvailable": .variable("allAvailable"),
        "markedForDeletionOn": .variable("markedForDeletionOn"),
        "active": .variable("active")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GroupsQuery.Data.self
    ] }

    /// Find groups.
    public var groups: Groups? { __data["groups"] }

    /// Groups
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
        GroupsQuery.Data.Groups.self
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node?]? { __data["nodes"] }

      /// Groups.PageInfo
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
          GroupsQuery.Data.Groups.PageInfo.self
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// Groups.Node
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
          .field("maxAccessLevel", MaxAccessLevel.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GroupsQuery.Data.Groups.Node.self
        ] }

        /// Avatar URL of the group.
        public var avatarUrl: String? { __data["avatarUrl"] }
        /// Name of the group.
        public var name: String? { __data["name"] }
        /// Full path of the namespace.
        public var fullPath: GitLabAPI.ID { __data["fullPath"] }
        /// Visibility of the namespace.
        public var visibility: String? { __data["visibility"] }
        /// Maximum access level of the current user in the group.
        public var maxAccessLevel: MaxAccessLevel { __data["maxAccessLevel"] }

        /// Groups.Node.MaxAccessLevel
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
            GroupsQuery.Data.Groups.Node.MaxAccessLevel.self
          ] }

          /// Enum string of the the access level.
          public var stringValue: GraphQLEnum<GitLabAPI.AccessLevelEnum>? { __data["stringValue"] }
        }
      }
    }
  }
}
