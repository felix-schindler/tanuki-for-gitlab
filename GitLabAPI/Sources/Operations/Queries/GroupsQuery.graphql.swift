// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct GroupsQuery: GraphQLQuery {
  public static let operationName: String = "Groups"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Groups($topLevelOnly: Boolean, $ownedOnly: Boolean, $search: String, $parentPath: ID, $allAvailable: Boolean, $markedForDeletionOn: Date, $active: Boolean) { groups( topLevelOnly: $topLevelOnly ownedOnly: $ownedOnly search: $search parentPath: $parentPath allAvailable: $allAvailable markedForDeletionOn: $markedForDeletionOn active: $active ) { __typename nodes { __typename avatarUrl name fullPath visibility maxAccessLevel { __typename stringValue } } } }"#
    ))

  public var topLevelOnly: GraphQLNullable<Bool>
  public var ownedOnly: GraphQLNullable<Bool>
  public var search: GraphQLNullable<String>
  public var parentPath: GraphQLNullable<ID>
  public var allAvailable: GraphQLNullable<Bool>
  public var markedForDeletionOn: GraphQLNullable<Date>
  public var active: GraphQLNullable<Bool>

  public init(
    topLevelOnly: GraphQLNullable<Bool>,
    ownedOnly: GraphQLNullable<Bool>,
    search: GraphQLNullable<String>,
    parentPath: GraphQLNullable<ID>,
    allAvailable: GraphQLNullable<Bool>,
    markedForDeletionOn: GraphQLNullable<Date>,
    active: GraphQLNullable<Bool>
  ) {
    self.topLevelOnly = topLevelOnly
    self.ownedOnly = ownedOnly
    self.search = search
    self.parentPath = parentPath
    self.allAvailable = allAvailable
    self.markedForDeletionOn = markedForDeletionOn
    self.active = active
  }

  @_spi(Unsafe) public var __variables: Variables? { [
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
        .field("nodes", [Node?]?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GroupsQuery.Data.Groups.self
      ] }

      /// A list of nodes.
      public var nodes: [Node?]? { __data["nodes"] }

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
