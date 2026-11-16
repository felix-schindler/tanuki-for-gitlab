// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct ProjectsQuery: GraphQLQuery {
  public static let operationName: String = "Projects"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Projects($first: Int!, $after: String, $membership: Boolean, $search: String, $personal: Boolean, $sort: String, $withIssuesEnabled: Boolean, $withMergeRequestsEnabled: Boolean, $archived: ProjectArchived, $minAccessLevel: AccessLevelEnum, $aimedForDeletion: Boolean, $notAimedForDeletion: Boolean, $markedForDeletionOn: Date, $active: Boolean) { projects( first: $first after: $after membership: $membership search: $search personal: $personal sort: $sort withIssuesEnabled: $withIssuesEnabled withMergeRequestsEnabled: $withMergeRequestsEnabled archived: $archived minAccessLevel: $minAccessLevel aimedForDeletion: $aimedForDeletion notAimedForDeletion: $notAimedForDeletion markedForDeletionOn: $markedForDeletionOn active: $active ) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename avatarUrl nameWithNamespace visibility fullPath archived } } }"#
    ))

  public var first: Int32
  public var after: GraphQLNullable<String>
  public var membership: GraphQLNullable<Bool>
  public var search: GraphQLNullable<String>
  public var personal: GraphQLNullable<Bool>
  public var sort: GraphQLNullable<String>
  public var withIssuesEnabled: GraphQLNullable<Bool>
  public var withMergeRequestsEnabled: GraphQLNullable<Bool>
  public var archived: GraphQLNullable<GraphQLEnum<ProjectArchived>>
  public var minAccessLevel: GraphQLNullable<GraphQLEnum<AccessLevelEnum>>
  public var aimedForDeletion: GraphQLNullable<Bool>
  public var notAimedForDeletion: GraphQLNullable<Bool>
  public var markedForDeletionOn: GraphQLNullable<Date>
  public var active: GraphQLNullable<Bool>

  public init(
    first: Int32,
    after: GraphQLNullable<String>,
    membership: GraphQLNullable<Bool>,
    search: GraphQLNullable<String>,
    personal: GraphQLNullable<Bool>,
    sort: GraphQLNullable<String>,
    withIssuesEnabled: GraphQLNullable<Bool>,
    withMergeRequestsEnabled: GraphQLNullable<Bool>,
    archived: GraphQLNullable<GraphQLEnum<ProjectArchived>>,
    minAccessLevel: GraphQLNullable<GraphQLEnum<AccessLevelEnum>>,
    aimedForDeletion: GraphQLNullable<Bool>,
    notAimedForDeletion: GraphQLNullable<Bool>,
    markedForDeletionOn: GraphQLNullable<Date>,
    active: GraphQLNullable<Bool>
  ) {
    self.first = first
    self.after = after
    self.membership = membership
    self.search = search
    self.personal = personal
    self.sort = sort
    self.withIssuesEnabled = withIssuesEnabled
    self.withMergeRequestsEnabled = withMergeRequestsEnabled
    self.archived = archived
    self.minAccessLevel = minAccessLevel
    self.aimedForDeletion = aimedForDeletion
    self.notAimedForDeletion = notAimedForDeletion
    self.markedForDeletionOn = markedForDeletionOn
    self.active = active
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "first": first,
    "after": after,
    "membership": membership,
    "search": search,
    "personal": personal,
    "sort": sort,
    "withIssuesEnabled": withIssuesEnabled,
    "withMergeRequestsEnabled": withMergeRequestsEnabled,
    "archived": archived,
    "minAccessLevel": minAccessLevel,
    "aimedForDeletion": aimedForDeletion,
    "notAimedForDeletion": notAimedForDeletion,
    "markedForDeletionOn": markedForDeletionOn,
    "active": active
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("projects", Projects?.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after"),
        "membership": .variable("membership"),
        "search": .variable("search"),
        "personal": .variable("personal"),
        "sort": .variable("sort"),
        "withIssuesEnabled": .variable("withIssuesEnabled"),
        "withMergeRequestsEnabled": .variable("withMergeRequestsEnabled"),
        "archived": .variable("archived"),
        "minAccessLevel": .variable("minAccessLevel"),
        "aimedForDeletion": .variable("aimedForDeletion"),
        "notAimedForDeletion": .variable("notAimedForDeletion"),
        "markedForDeletionOn": .variable("markedForDeletionOn"),
        "active": .variable("active")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ProjectsQuery.Data.self
    ] }

    /// Find projects visible to the current user.
    public var projects: Projects? { __data["projects"] }

    /// Projects
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
        ProjectsQuery.Data.Projects.self
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node?]? { __data["nodes"] }

      /// Projects.PageInfo
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
          ProjectsQuery.Data.Projects.PageInfo.self
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// Projects.Node
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
          ProjectsQuery.Data.Projects.Node.self
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
