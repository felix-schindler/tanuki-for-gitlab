// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct ProjectMembersQuery: GraphQLQuery {
  public static let operationName: String = "ProjectMembers"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ProjectMembers($first: Int!, $after: String, $fullPath: ID!) { project(fullPath: $fullPath) { __typename projectMembers(first: $first, after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename id createdBy { __typename avatarUrl name username } createdAt expiresAt accessLevel { __typename stringValue } user { __typename avatarUrl name username } } } } }"#
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
      .field("project", Project?.self, arguments: ["fullPath": .variable("fullPath")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ProjectMembersQuery.Data.self
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
        .field("projectMembers", ProjectMembers?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ProjectMembersQuery.Data.Project.self
      ] }

      /// Members of the project.
      public var projectMembers: ProjectMembers? { __data["projectMembers"] }

      /// Project.ProjectMembers
      ///
      /// Parent Type: `MemberInterfaceConnection`
      nonisolated public struct ProjectMembers: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MemberInterfaceConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node?]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProjectMembersQuery.Data.Project.ProjectMembers.self
        ] }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Project.ProjectMembers.PageInfo
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
            ProjectMembersQuery.Data.Project.ProjectMembers.PageInfo.self
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
        }

        /// Project.ProjectMembers.Node
        ///
        /// Parent Type: `MemberInterface`
        nonisolated public struct Node: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Interfaces.MemberInterface }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GitLabAPI.ID.self),
            .field("createdBy", CreatedBy?.self),
            .field("createdAt", GitLabAPI.Time?.self),
            .field("expiresAt", GitLabAPI.Time?.self),
            .field("accessLevel", AccessLevel?.self),
            .field("user", User?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProjectMembersQuery.Data.Project.ProjectMembers.Node.self
          ] }

          /// ID of the member.
          public var id: GitLabAPI.ID { __data["id"] }
          /// User that authorized membership.
          public var createdBy: CreatedBy? { __data["createdBy"] }
          /// Date and time the membership was created.
          public var createdAt: GitLabAPI.Time? { __data["createdAt"] }
          /// Date and time the membership expires.
          public var expiresAt: GitLabAPI.Time? { __data["expiresAt"] }
          /// GitLab::Access level.
          public var accessLevel: AccessLevel? { __data["accessLevel"] }
          /// User that is associated with the member object.
          public var user: User? { __data["user"] }

          /// Project.ProjectMembers.Node.CreatedBy
          ///
          /// Parent Type: `UserCore`
          nonisolated public struct CreatedBy: GitLabAPI.SelectionSet {
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
              ProjectMembersQuery.Data.Project.ProjectMembers.Node.CreatedBy.self
            ] }

            /// URL of the user's avatar.
            public var avatarUrl: String? { __data["avatarUrl"] }
            /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
            public var name: String { __data["name"] }
            /// Username of the user. Unique within the instance of GitLab.
            public var username: String { __data["username"] }
          }

          /// Project.ProjectMembers.Node.AccessLevel
          ///
          /// Parent Type: `AccessLevel`
          nonisolated public struct AccessLevel: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.AccessLevel }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("stringValue", GraphQLEnum<GitLabAPI.AccessLevelEnum>?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ProjectMembersQuery.Data.Project.ProjectMembers.Node.AccessLevel.self
            ] }

            /// Enum string of the the access level.
            public var stringValue: GraphQLEnum<GitLabAPI.AccessLevelEnum>? { __data["stringValue"] }
          }

          /// Project.ProjectMembers.Node.User
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
              ProjectMembersQuery.Data.Project.ProjectMembers.Node.User.self
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
