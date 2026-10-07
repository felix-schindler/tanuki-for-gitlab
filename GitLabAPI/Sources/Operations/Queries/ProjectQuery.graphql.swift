// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct ProjectQuery: GraphQLQuery {
  public static let operationName: String = "Project"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Project($fullPath: ID!) { project(fullPath: $fullPath) { __typename id avatarUrl name visibility description topics starCount forksCount issuesEnabled openIssuesCount mergeRequestsEnabled jobsEnabled openMergeRequestsCount webUrl httpUrlToRepo sshUrlToRepo createdAt archived namespace { __typename id name fullPath } statistics { __typename commitCount repositorySize } repository { __typename rootRef readme: blobs(paths: ["README.md", "README", "README.txt"], first: 1) { __typename nodes { __typename rawTextBlob } } license: blobs( paths: ["LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING"] first: 1 ) { __typename nodes { __typename rawTextBlob } } contributing: blobs( paths: ["CONTRIBUTING", "CONTRIBUTING.txt", "CONTRIBUTING.md"] first: 1 ) { __typename nodes { __typename rawTextBlob } } tree { __typename lastCommit { __typename id title shortId authorName authoredDate webUrl signature { __typename verificationStatus } pipelines { __typename nodes { __typename status } } } } } languages { __typename name share color } userPermissions { __typename createIssue forkProject requestAccess } } }"#
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
      .field("project", Project?.self, arguments: ["fullPath": .variable("fullPath")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ProjectQuery.Data.self
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
        .field("id", GitLabAPI.ID.self),
        .field("avatarUrl", String?.self),
        .field("name", String.self),
        .field("visibility", String?.self),
        .field("description", String?.self),
        .field("topics", [String]?.self),
        .field("starCount", Int.self),
        .field("forksCount", Int.self),
        .field("issuesEnabled", Bool?.self),
        .field("openIssuesCount", Int?.self),
        .field("mergeRequestsEnabled", Bool?.self),
        .field("jobsEnabled", Bool?.self),
        .field("openMergeRequestsCount", Int?.self),
        .field("webUrl", String?.self),
        .field("httpUrlToRepo", String?.self),
        .field("sshUrlToRepo", String?.self),
        .field("createdAt", GitLabAPI.Time?.self),
        .field("archived", Bool?.self),
        .field("namespace", Namespace?.self),
        .field("statistics", Statistics?.self),
        .field("repository", Repository?.self),
        .field("languages", [Language]?.self),
        .field("userPermissions", UserPermissions.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ProjectQuery.Data.Project.self
      ] }

      /// ID of the project.
      public var id: GitLabAPI.ID { __data["id"] }
      /// Avatar URL of the project.
      public var avatarUrl: String? { __data["avatarUrl"] }
      /// Name of the project without the namespace.
      public var name: String { __data["name"] }
      /// Visibility of the project.
      public var visibility: String? { __data["visibility"] }
      /// Short description of the project.
      public var description: String? { __data["description"] }
      /// List of project topics.
      public var topics: [String]? { __data["topics"] }
      /// Number of times the project has been starred.
      public var starCount: Int { __data["starCount"] }
      /// Number of times the project has been forked.
      public var forksCount: Int { __data["forksCount"] }
      /// Indicates if Issues are enabled for the current user
      public var issuesEnabled: Bool? { __data["issuesEnabled"] }
      /// Number of open issues for the project.
      public var openIssuesCount: Int? { __data["openIssuesCount"] }
      /// Indicates if Merge requests are enabled for the current user
      public var mergeRequestsEnabled: Bool? { __data["mergeRequestsEnabled"] }
      /// Indicates if CI/CD pipeline jobs are enabled for the current user.
      public var jobsEnabled: Bool? { __data["jobsEnabled"] }
      /// Number of open merge requests for the project.
      public var openMergeRequestsCount: Int? { __data["openMergeRequestsCount"] }
      /// Web URL of the project.
      public var webUrl: String? { __data["webUrl"] }
      /// URL to connect to the project via HTTPS.
      public var httpUrlToRepo: String? { __data["httpUrlToRepo"] }
      /// URL to connect to the project via SSH.
      public var sshUrlToRepo: String? { __data["sshUrlToRepo"] }
      /// Timestamp of the project creation.
      public var createdAt: GitLabAPI.Time? { __data["createdAt"] }
      /// Indicates the archived status of the project.
      public var archived: Bool? { __data["archived"] }
      /// Namespace of the project.
      public var namespace: Namespace? { __data["namespace"] }
      /// Statistics of the project.
      public var statistics: Statistics? { __data["statistics"] }
      /// Git repository of the project.
      public var repository: Repository? { __data["repository"] }
      /// Programming languages used in the project.
      public var languages: [Language]? { __data["languages"] }
      /// Permissions for the current user on the resource
      public var userPermissions: UserPermissions { __data["userPermissions"] }

      /// Project.Namespace
      ///
      /// Parent Type: `Namespace`
      nonisolated public struct Namespace: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Namespace }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GitLabAPI.ID.self),
          .field("name", String.self),
          .field("fullPath", GitLabAPI.ID.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProjectQuery.Data.Project.Namespace.self
        ] }

        /// ID of the namespace.
        public var id: GitLabAPI.ID { __data["id"] }
        /// Name of the namespace.
        public var name: String { __data["name"] }
        /// Full path of the namespace.
        public var fullPath: GitLabAPI.ID { __data["fullPath"] }
      }

      /// Project.Statistics
      ///
      /// Parent Type: `ProjectStatistics`
      nonisolated public struct Statistics: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.ProjectStatistics }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("commitCount", Double.self),
          .field("repositorySize", Double.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProjectQuery.Data.Project.Statistics.self
        ] }

        /// Commit count of the project.
        public var commitCount: Double { __data["commitCount"] }
        /// Repository size of the project in bytes.
        public var repositorySize: Double { __data["repositorySize"] }
      }

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
          .field("blobs", alias: "readme", Readme?.self, arguments: [
            "paths": ["README.md", "README", "README.txt"],
            "first": 1
          ]),
          .field("blobs", alias: "license", License?.self, arguments: [
            "paths": ["LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING"],
            "first": 1
          ]),
          .field("blobs", alias: "contributing", Contributing?.self, arguments: [
            "paths": ["CONTRIBUTING", "CONTRIBUTING.txt", "CONTRIBUTING.md"],
            "first": 1
          ]),
          .field("tree", Tree?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProjectQuery.Data.Project.Repository.self
        ] }

        /// Default branch of the repository.
        public var rootRef: String? { __data["rootRef"] }
        /// Blobs contained within the repository
        public var readme: Readme? { __data["readme"] }
        /// Blobs contained within the repository
        public var license: License? { __data["license"] }
        /// Blobs contained within the repository
        public var contributing: Contributing? { __data["contributing"] }
        /// Tree of the repository.
        public var tree: Tree? { __data["tree"] }

        /// Project.Repository.Readme
        ///
        /// Parent Type: `RepositoryBlobConnection`
        nonisolated public struct Readme: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.RepositoryBlobConnection }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProjectQuery.Data.Project.Repository.Readme.self
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }

          /// Project.Repository.Readme.Node
          ///
          /// Parent Type: `RepositoryBlob`
          nonisolated public struct Node: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.RepositoryBlob }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("rawTextBlob", String?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ProjectQuery.Data.Project.Repository.Readme.Node.self
            ] }

            /// Raw content of the blob, if the blob is text data.
            public var rawTextBlob: String? { __data["rawTextBlob"] }
          }
        }

        /// Project.Repository.License
        ///
        /// Parent Type: `RepositoryBlobConnection`
        nonisolated public struct License: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.RepositoryBlobConnection }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProjectQuery.Data.Project.Repository.License.self
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }

          /// Project.Repository.License.Node
          ///
          /// Parent Type: `RepositoryBlob`
          nonisolated public struct Node: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.RepositoryBlob }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("rawTextBlob", String?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ProjectQuery.Data.Project.Repository.License.Node.self
            ] }

            /// Raw content of the blob, if the blob is text data.
            public var rawTextBlob: String? { __data["rawTextBlob"] }
          }
        }

        /// Project.Repository.Contributing
        ///
        /// Parent Type: `RepositoryBlobConnection`
        nonisolated public struct Contributing: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.RepositoryBlobConnection }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProjectQuery.Data.Project.Repository.Contributing.self
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }

          /// Project.Repository.Contributing.Node
          ///
          /// Parent Type: `RepositoryBlob`
          nonisolated public struct Node: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.RepositoryBlob }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("rawTextBlob", String?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ProjectQuery.Data.Project.Repository.Contributing.Node.self
            ] }

            /// Raw content of the blob, if the blob is text data.
            public var rawTextBlob: String? { __data["rawTextBlob"] }
          }
        }

        /// Project.Repository.Tree
        ///
        /// Parent Type: `Tree`
        nonisolated public struct Tree: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Tree }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("lastCommit", LastCommit?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProjectQuery.Data.Project.Repository.Tree.self
          ] }

          /// Last commit for the tree.
          public var lastCommit: LastCommit? { __data["lastCommit"] }

          /// Project.Repository.Tree.LastCommit
          ///
          /// Parent Type: `Commit`
          nonisolated public struct LastCommit: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Commit }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", GitLabAPI.ID.self),
              .field("title", String?.self),
              .field("shortId", String.self),
              .field("authorName", String?.self),
              .field("authoredDate", GitLabAPI.Time?.self),
              .field("webUrl", String.self),
              .field("signature", Signature?.self),
              .field("pipelines", Pipelines?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ProjectQuery.Data.Project.Repository.Tree.LastCommit.self
            ] }

            /// ID (global ID) of the commit.
            public var id: GitLabAPI.ID { __data["id"] }
            /// Title of the commit message.
            public var title: String? { __data["title"] }
            /// Short SHA1 ID of the commit.
            public var shortId: String { __data["shortId"] }
            /// Commit authors name.
            public var authorName: String? { __data["authorName"] }
            /// Timestamp of when the commit was authored.
            public var authoredDate: GitLabAPI.Time? { __data["authoredDate"] }
            /// Web URL of the commit.
            public var webUrl: String { __data["webUrl"] }
            /// Signature of the commit.
            public var signature: Signature? { __data["signature"] }
            /// Pipelines of the commit ordered latest first.
            public var pipelines: Pipelines? { __data["pipelines"] }

            /// Project.Repository.Tree.LastCommit.Signature
            ///
            /// Parent Type: `CommitSignature`
            nonisolated public struct Signature: GitLabAPI.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Interfaces.CommitSignature }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("verificationStatus", GraphQLEnum<GitLabAPI.VerificationStatus>?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ProjectQuery.Data.Project.Repository.Tree.LastCommit.Signature.self
              ] }

              /// Indicates verification status of the associated key or certificate.
              public var verificationStatus: GraphQLEnum<GitLabAPI.VerificationStatus>? { __data["verificationStatus"] }
            }

            /// Project.Repository.Tree.LastCommit.Pipelines
            ///
            /// Parent Type: `PipelineConnection`
            nonisolated public struct Pipelines: GitLabAPI.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.PipelineConnection }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("nodes", [Node?]?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ProjectQuery.Data.Project.Repository.Tree.LastCommit.Pipelines.self
              ] }

              /// A list of nodes.
              public var nodes: [Node?]? { __data["nodes"] }

              /// Project.Repository.Tree.LastCommit.Pipelines.Node
              ///
              /// Parent Type: `Pipeline`
              nonisolated public struct Node: GitLabAPI.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Pipeline }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("status", GraphQLEnum<GitLabAPI.PipelineStatusEnum>.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  ProjectQuery.Data.Project.Repository.Tree.LastCommit.Pipelines.Node.self
                ] }

                /// Status of the pipeline (CREATED, WAITING_FOR_RESOURCE, PREPARING, WAITING_FOR_CALLBACK, PENDING, RUNNING, FAILED, SUCCESS, CANCELED, CANCELING, SKIPPED, MANUAL, SCHEDULED)
                public var status: GraphQLEnum<GitLabAPI.PipelineStatusEnum> { __data["status"] }
              }
            }
          }
        }
      }

      /// Project.Language
      ///
      /// Parent Type: `RepositoryLanguage`
      nonisolated public struct Language: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.RepositoryLanguage }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("share", Double?.self),
          .field("color", GitLabAPI.Color?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProjectQuery.Data.Project.Language.self
        ] }

        /// Name of the repository language.
        public var name: String { __data["name"] }
        /// Percentage of the repository's languages.
        public var share: Double? { __data["share"] }
        /// Color to visualize the repository language.
        public var color: GitLabAPI.Color? { __data["color"] }
      }

      /// Project.UserPermissions
      ///
      /// Parent Type: `ProjectPermissions`
      nonisolated public struct UserPermissions: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.ProjectPermissions }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("createIssue", Bool.self),
          .field("forkProject", Bool.self),
          .field("requestAccess", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProjectQuery.Data.Project.UserPermissions.self
        ] }

        /// If `true`, the user can perform `create_issue` on this resource
        public var createIssue: Bool { __data["createIssue"] }
        /// If `true`, the user can perform `fork_project` on this resource
        public var forkProject: Bool { __data["forkProject"] }
        /// If `true`, the user can perform `request_access` on this resource
        public var requestAccess: Bool { __data["requestAccess"] }
      }
    }
  }
}
