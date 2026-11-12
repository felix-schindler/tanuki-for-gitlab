// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct GroupQuery: GraphQLQuery {
  public static let operationName: String = "Group"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Group($fullPath: ID!) { group(fullPath: $fullPath) { __typename id avatarUrl name path visibility description descendantGroupsCount groupMembersCount projectsCount requestAccessEnabled webUrl maxAccessLevel { __typename stringValue } userPermissions { __typename createProjects } parent { __typename name fullPath } } }"#
    ))

  public var fullPath: ID

  public init(fullPath: ID) {
    self.fullPath = fullPath
  }

  @_spi(Unsafe) public var __variables: Variables? { ["fullPath": fullPath] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("group", Group?.self, arguments: ["fullPath": .variable("fullPath")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GroupQuery.Data.self
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
        .field("id", GitLabAPI.ID?.self),
        .field("avatarUrl", String?.self),
        .field("name", String?.self),
        .field("path", String.self),
        .field("visibility", String?.self),
        .field("description", String?.self),
        .field("descendantGroupsCount", Int.self),
        .field("groupMembersCount", Int.self),
        .field("projectsCount", Int.self),
        .field("requestAccessEnabled", Bool?.self),
        .field("webUrl", String.self),
        .field("maxAccessLevel", MaxAccessLevel.self),
        .field("userPermissions", UserPermissions.self),
        .field("parent", Parent?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GroupQuery.Data.Group.self
      ] }

      /// ID of the group.
      public var id: GitLabAPI.ID? { __data["id"] }
      /// Avatar URL of the group.
      public var avatarUrl: String? { __data["avatarUrl"] }
      /// Name of the group.
      public var name: String? { __data["name"] }
      /// Path of the namespace.
      public var path: String { __data["path"] }
      /// Visibility of the namespace.
      public var visibility: String? { __data["visibility"] }
      /// Description of the namespace.
      public var description: String? { __data["description"] }
      /// Count of direct descendant groups of the group.
      public var descendantGroupsCount: Int { __data["descendantGroupsCount"] }
      /// Count of direct members of the group.
      public var groupMembersCount: Int { __data["groupMembersCount"] }
      /// Count of direct projects in the group.
      public var projectsCount: Int { __data["projectsCount"] }
      /// Indicates if users can request access to namespace.
      public var requestAccessEnabled: Bool? { __data["requestAccessEnabled"] }
      /// Web URL of the group.
      public var webUrl: String { __data["webUrl"] }
      /// Maximum access level of the current user in the group.
      public var maxAccessLevel: MaxAccessLevel { __data["maxAccessLevel"] }
      /// Permissions for the current user on the resource
      public var userPermissions: UserPermissions { __data["userPermissions"] }
      /// Parent group.
      public var parent: Parent? { __data["parent"] }

      /// Group.MaxAccessLevel
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
          GroupQuery.Data.Group.MaxAccessLevel.self
        ] }

        /// Enum string of the the access level.
        public var stringValue: GraphQLEnum<GitLabAPI.AccessLevelEnum>? { __data["stringValue"] }
      }

      /// Group.UserPermissions
      ///
      /// Parent Type: `GroupPermissions`
      nonisolated public struct UserPermissions: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.GroupPermissions }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("createProjects", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GroupQuery.Data.Group.UserPermissions.self
        ] }

        /// If `true`, the user can perform `create_projects` on this resource
        public var createProjects: Bool { __data["createProjects"] }
      }

      /// Group.Parent
      ///
      /// Parent Type: `Group`
      nonisolated public struct Parent: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Group }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String?.self),
          .field("fullPath", GitLabAPI.ID.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GroupQuery.Data.Group.Parent.self
        ] }

        /// Name of the group.
        public var name: String? { __data["name"] }
        /// Full path of the namespace.
        public var fullPath: GitLabAPI.ID { __data["fullPath"] }
      }
    }
  }
}
