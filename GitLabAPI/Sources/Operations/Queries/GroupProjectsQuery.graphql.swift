// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct GroupProjectsQuery: GraphQLQuery {
  public static let operationName: String = "GroupProjects"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GroupProjects($first: Int!, $after: String, $fullPath: ID!) { group(fullPath: $fullPath) { __typename projects(first: $first, after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename avatarUrl nameWithNamespace visibility fullPath archived } } } }"#
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
      GroupProjectsQuery.Data.self
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
        .field("projects", Projects.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GroupProjectsQuery.Data.Group.self
      ] }

      /// Projects within this namespace. Returns projects from the parent group if namespace is project.
      public var projects: Projects { __data["projects"] }

      /// Group.Projects
      ///
      /// Parent Type: `ProjectConnection`
      nonisolated public struct Projects: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.ProjectConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node?]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GroupProjectsQuery.Data.Group.Projects.self
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Group.Projects.PageInfo
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
            GroupProjectsQuery.Data.Group.Projects.PageInfo.self
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// Group.Projects.Node
        ///
        /// Parent Type: `Project`
        nonisolated public struct Node: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Project }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("avatarUrl", String?.self),
            .field("nameWithNamespace", String.self),
            .field("visibility", String?.self),
            .field("fullPath", GitLabAPI.ID.self),
            .field("archived", Bool?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GroupProjectsQuery.Data.Group.Projects.Node.self
          ] }

          /// Avatar URL of the project.
          public var avatarUrl: String? { __data["avatarUrl"] }
          /// Name of the project including the namespace.
          public var nameWithNamespace: String { __data["nameWithNamespace"] }
          /// Visibility of the project.
          public var visibility: String? { __data["visibility"] }
          /// Full path of the project.
          public var fullPath: GitLabAPI.ID { __data["fullPath"] }
          /// Indicates the archived status of the project.
          public var archived: Bool? { __data["archived"] }
        }
      }
    }
  }
}
