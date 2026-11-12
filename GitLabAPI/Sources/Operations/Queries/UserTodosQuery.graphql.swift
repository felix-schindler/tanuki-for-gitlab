// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct UserTodosQuery: GraphQLQuery {
  public static let operationName: String = "UserTodos"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query UserTodos($username: String!) { user(username: $username) { __typename todos { __typename nodes { __typename id body group { __typename fullPath } state action author { __typename avatarUrl name username } targetEntity { __typename webUrl } project { __typename avatarUrl fullPath nameWithNamespace visibility archived } createdAt targetType } } } }"#
    ))

  public var username: String

  public init(username: String) {
    self.username = username
  }

  @_spi(Unsafe) public var __variables: Variables? { ["username": username] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("user", User?.self, arguments: ["username": .variable("username")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UserTodosQuery.Data.self
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
        .field("todos", Todos?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UserTodosQuery.Data.User.self
      ] }

      /// To-do items of the user.
      public var todos: Todos? { __data["todos"] }

      /// User.Todos
      ///
      /// Parent Type: `TodoConnection`
      nonisolated public struct Todos: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.TodoConnection }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UserTodosQuery.Data.User.Todos.self
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// User.Todos.Node
        ///
        /// Parent Type: `Todo`
        nonisolated public struct Node: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Todo }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GitLabAPI.ID.self),
            .field("body", String.self),
            .field("group", Group?.self),
            .field("state", GraphQLEnum<GitLabAPI.TodoStateEnum>.self),
            .field("action", GraphQLEnum<GitLabAPI.TodoActionEnum>.self),
            .field("author", Author.self),
            .field("targetEntity", TargetEntity?.self),
            .field("project", Project?.self),
            .field("createdAt", GitLabAPI.Time.self),
            .field("targetType", GraphQLEnum<GitLabAPI.TodoTargetEnum>.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            UserTodosQuery.Data.User.Todos.Node.self
          ] }

          /// ID of the to-do item.
          public var id: GitLabAPI.ID { __data["id"] }
          /// Body of the to-do item.
          public var body: String { __data["body"] }
          /// Group the to-do item is associated with.
          public var group: Group? { __data["group"] }
          /// State of the to-do item.
          public var state: GraphQLEnum<GitLabAPI.TodoStateEnum> { __data["state"] }
          /// Action of the to-do item.
          public var action: GraphQLEnum<GitLabAPI.TodoActionEnum> { __data["action"] }
          /// Author of the to-do item.
          public var author: Author { __data["author"] }
          /// Target of the to-do item.
          public var targetEntity: TargetEntity? { __data["targetEntity"] }
          /// Project the to-do item is associated with.
          public var project: Project? { __data["project"] }
          /// Timestamp the to-do item was created.
          public var createdAt: GitLabAPI.Time { __data["createdAt"] }
          /// Target type of the to-do item.
          public var targetType: GraphQLEnum<GitLabAPI.TodoTargetEnum> { __data["targetType"] }

          /// User.Todos.Node.Group
          ///
          /// Parent Type: `Group`
          nonisolated public struct Group: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Group }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("fullPath", GitLabAPI.ID.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              UserTodosQuery.Data.User.Todos.Node.Group.self
            ] }

            /// Full path of the namespace.
            public var fullPath: GitLabAPI.ID { __data["fullPath"] }
          }

          /// User.Todos.Node.Author
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
              UserTodosQuery.Data.User.Todos.Node.Author.self
            ] }

            /// URL of the user's avatar.
            public var avatarUrl: String? { __data["avatarUrl"] }
            /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
            public var name: String { __data["name"] }
            /// Username of the user. Unique within the instance of GitLab.
            public var username: String { __data["username"] }
          }

          /// User.Todos.Node.TargetEntity
          ///
          /// Parent Type: `Todoable`
          nonisolated public struct TargetEntity: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Interfaces.Todoable }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("webUrl", String?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              UserTodosQuery.Data.User.Todos.Node.TargetEntity.self
            ] }

            /// URL of the object.
            public var webUrl: String? { __data["webUrl"] }
          }

          /// User.Todos.Node.Project
          ///
          /// Parent Type: `Project`
          nonisolated public struct Project: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Project }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("avatarUrl", String?.self),
              .field("fullPath", GitLabAPI.ID.self),
              .field("nameWithNamespace", String.self),
              .field("visibility", String?.self),
              .field("archived", Bool?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              UserTodosQuery.Data.User.Todos.Node.Project.self
            ] }

            /// Avatar URL of the project.
            public var avatarUrl: String? { __data["avatarUrl"] }
            /// Full path of the project.
            public var fullPath: GitLabAPI.ID { __data["fullPath"] }
            /// Name of the project including the namespace.
            public var nameWithNamespace: String { __data["nameWithNamespace"] }
            /// Visibility of the project.
            public var visibility: String? { __data["visibility"] }
            /// Indicates the archived status of the project.
            public var archived: Bool? { __data["archived"] }
          }
        }
      }
    }
  }
}
