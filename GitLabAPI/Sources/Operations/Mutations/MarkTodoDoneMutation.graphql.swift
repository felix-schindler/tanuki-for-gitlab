// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct MarkTodoDoneMutation: GraphQLMutation {
  public static let operationName: String = "MarkTodoDone"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation MarkTodoDone($id: TodoID!) { todoMarkDone(input: { id: $id }) { __typename errors todo { __typename id state } } }"#
    ))

  public var id: TodoID

  public init(id: TodoID) {
    self.id = id
  }

  @_spi(Unsafe) public var __variables: Variables? { ["id": id] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("todoMarkDone", TodoMarkDone?.self, arguments: ["input": ["id": .variable("id")]]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MarkTodoDoneMutation.Data.self
    ] }

    public var todoMarkDone: TodoMarkDone? { __data["todoMarkDone"] }

    /// TodoMarkDone
    ///
    /// Parent Type: `TodoMarkDonePayload`
    nonisolated public struct TodoMarkDone: GitLabAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.TodoMarkDonePayload }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("errors", [String].self),
        .field("todo", Todo.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MarkTodoDoneMutation.Data.TodoMarkDone.self
      ] }

      /// Errors encountered during the mutation.
      public var errors: [String] { __data["errors"] }
      /// Requested to-do item.
      public var todo: Todo { __data["todo"] }

      /// TodoMarkDone.Todo
      ///
      /// Parent Type: `Todo`
      nonisolated public struct Todo: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Todo }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GitLabAPI.ID.self),
          .field("state", GraphQLEnum<GitLabAPI.TodoStateEnum>.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MarkTodoDoneMutation.Data.TodoMarkDone.Todo.self
        ] }

        /// ID of the to-do item.
        public var id: GitLabAPI.ID { __data["id"] }
        /// State of the to-do item.
        public var state: GraphQLEnum<GitLabAPI.TodoStateEnum> { __data["state"] }
      }
    }
  }
}
