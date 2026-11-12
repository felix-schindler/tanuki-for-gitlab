// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct EntityIdQuery: GraphQLQuery {
  public static let operationName: String = "EntityId"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query EntityId($fullPath: ID!, $username: String!) { project(fullPath: $fullPath) { __typename id repository { __typename rootRef } } group(fullPath: $fullPath) { __typename id } user(username: $username) { __typename id } }"#
    ))

  public var fullPath: ID
  public var username: String

  public init(
    fullPath: ID,
    username: String
  ) {
    self.fullPath = fullPath
    self.username = username
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "fullPath": fullPath,
    "username": username
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["fullPath": .variable("fullPath")]),
      .field("group", Group?.self, arguments: ["fullPath": .variable("fullPath")]),
      .field("user", User?.self, arguments: ["username": .variable("username")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      EntityIdQuery.Data.self
    ] }

    /// Find a project.
    public var project: Project? { __data["project"] }
    /// Find a group.
    public var group: Group? { __data["group"] }
    /// Find a user.
    public var user: User? { __data["user"] }

    /// Project
    ///
    /// Parent Type: `Project`
    nonisolated public struct Project: GitLabAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Project }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GitLabAPI.ID.self),
        .field("repository", Repository?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        EntityIdQuery.Data.Project.self
      ] }

      /// ID of the project.
      public var id: GitLabAPI.ID { __data["id"] }
      /// Git repository of the project.
      public var repository: Repository? { __data["repository"] }

      /// Project.Repository
      ///
      /// Parent Type: `Repository`
      nonisolated public struct Repository: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Repository }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("rootRef", String?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          EntityIdQuery.Data.Project.Repository.self
        ] }

        /// Default branch of the repository.
        public var rootRef: String? { __data["rootRef"] }
      }
    }

    /// Group
    ///
    /// Parent Type: `Group`
    nonisolated public struct Group: GitLabAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Group }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GitLabAPI.ID?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        EntityIdQuery.Data.Group.self
      ] }

      /// ID of the group.
      public var id: GitLabAPI.ID? { __data["id"] }
    }

    /// User
    ///
    /// Parent Type: `UserCore`
    nonisolated public struct User: GitLabAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCore }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GitLabAPI.UserID.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        EntityIdQuery.Data.User.self
      ] }

      /// Global ID of the user.
      public var id: GitLabAPI.UserID { __data["id"] }
    }
  }
}
