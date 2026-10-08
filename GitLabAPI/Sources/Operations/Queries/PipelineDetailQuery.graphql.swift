// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct PipelineDetailQuery: GraphQLQuery {
  public static let operationName: String = "PipelineDetail"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query PipelineDetail($fullPath: ID!, $iid: ID!) { project(fullPath: $fullPath) { __typename pipeline(iid: $iid) { __typename id iid name status ref sha source createdAt startedAt finishedAt duration user { __typename avatarUrl name username } stages { __typename nodes { __typename name status jobs { __typename nodes { __typename id name status duration startedAt finishedAt failureMessage allowFailure artifacts { __typename nodes { __typename name size fileType } } } } } } } } }"#
    ))

  public var fullPath: ID
  public var iid: ID

  public init(
    fullPath: ID,
    iid: ID
  ) {
    self.fullPath = fullPath
    self.iid = iid
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "fullPath": fullPath,
    "iid": iid
  ] }

  nonisolated public struct Data: GitLabAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["fullPath": .variable("fullPath")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      PipelineDetailQuery.Data.self
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
        .field("pipeline", Pipeline?.self, arguments: ["iid": .variable("iid")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PipelineDetailQuery.Data.Project.self
      ] }

      /// Pipeline of the project. If no arguments are provided, returns the latest pipeline for the head commit on the default branch
      public var pipeline: Pipeline? { __data["pipeline"] }

      /// Project.Pipeline
      ///
      /// Parent Type: `Pipeline`
      nonisolated public struct Pipeline: GitLabAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Pipeline }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GitLabAPI.ID.self),
          .field("iid", String.self),
          .field("name", String?.self),
          .field("status", GraphQLEnum<GitLabAPI.PipelineStatusEnum>.self),
          .field("ref", String?.self),
          .field("sha", String?.self),
          .field("source", String?.self),
          .field("createdAt", GitLabAPI.Time.self),
          .field("startedAt", GitLabAPI.Time?.self),
          .field("finishedAt", GitLabAPI.Time?.self),
          .field("duration", Int?.self),
          .field("user", User?.self),
          .field("stages", Stages?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PipelineDetailQuery.Data.Project.Pipeline.self
        ] }

        /// ID of the pipeline.
        public var id: GitLabAPI.ID { __data["id"] }
        /// Internal ID of the pipeline.
        public var iid: String { __data["iid"] }
        /// Name of the pipeline.
        public var name: String? { __data["name"] }
        /// Status of the pipeline (CREATED, WAITING_FOR_RESOURCE, PREPARING, WAITING_FOR_CALLBACK, PENDING, RUNNING, FAILED, SUCCESS, CANCELED, CANCELING, SKIPPED, MANUAL, SCHEDULED)
        public var status: GraphQLEnum<GitLabAPI.PipelineStatusEnum> { __data["status"] }
        /// Reference to the branch from which the pipeline was triggered.
        public var ref: String? { __data["ref"] }
        /// SHA of the pipeline's commit.
        public var sha: String? { __data["sha"] }
        /// Source of the pipeline.
        public var source: String? { __data["source"] }
        /// Timestamp of the pipeline's creation.
        public var createdAt: GitLabAPI.Time { __data["createdAt"] }
        /// Timestamp when the pipeline was started.
        public var startedAt: GitLabAPI.Time? { __data["startedAt"] }
        /// Timestamp of the pipeline's completion.
        public var finishedAt: GitLabAPI.Time? { __data["finishedAt"] }
        /// Duration of the pipeline in seconds.
        public var duration: Int? { __data["duration"] }
        /// Pipeline user.
        public var user: User? { __data["user"] }
        /// Stages of the pipeline.
        public var stages: Stages? { __data["stages"] }

        /// Project.Pipeline.User
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
            PipelineDetailQuery.Data.Project.Pipeline.User.self
          ] }

          /// URL of the user's avatar.
          public var avatarUrl: String? { __data["avatarUrl"] }
          /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
          public var name: String { __data["name"] }
          /// Username of the user. Unique within the instance of GitLab.
          public var username: String { __data["username"] }
        }

        /// Project.Pipeline.Stages
        ///
        /// Parent Type: `CiStageConnection`
        nonisolated public struct Stages: GitLabAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.CiStageConnection }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PipelineDetailQuery.Data.Project.Pipeline.Stages.self
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }

          /// Project.Pipeline.Stages.Node
          ///
          /// Parent Type: `CiStage`
          nonisolated public struct Node: GitLabAPI.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.CiStage }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("name", String?.self),
              .field("status", String?.self),
              .field("jobs", Jobs?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              PipelineDetailQuery.Data.Project.Pipeline.Stages.Node.self
            ] }

            /// Name of the stage.
            public var name: String? { __data["name"] }
            /// Status of the pipeline stage.
            public var status: String? { __data["status"] }
            /// Jobs for the stage.
            public var jobs: Jobs? { __data["jobs"] }

            /// Project.Pipeline.Stages.Node.Jobs
            ///
            /// Parent Type: `CiJobConnection`
            nonisolated public struct Jobs: GitLabAPI.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.CiJobConnection }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("nodes", [Node?]?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                PipelineDetailQuery.Data.Project.Pipeline.Stages.Node.Jobs.self
              ] }

              /// A list of nodes.
              public var nodes: [Node?]? { __data["nodes"] }

              /// Project.Pipeline.Stages.Node.Jobs.Node
              ///
              /// Parent Type: `CiJob`
              nonisolated public struct Node: GitLabAPI.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.CiJob }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("id", GitLabAPI.JobID?.self),
                  .field("name", String?.self),
                  .field("status", GraphQLEnum<GitLabAPI.CiJobStatus>?.self),
                  .field("duration", Int?.self),
                  .field("startedAt", GitLabAPI.Time?.self),
                  .field("finishedAt", GitLabAPI.Time?.self),
                  .field("failureMessage", String?.self),
                  .field("allowFailure", Bool.self),
                  .field("artifacts", Artifacts?.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  PipelineDetailQuery.Data.Project.Pipeline.Stages.Node.Jobs.Node.self
                ] }

                /// ID of the job.
                public var id: GitLabAPI.JobID? { __data["id"] }
                /// Name of the job.
                public var name: String? { __data["name"] }
                /// Status of the job.
                public var status: GraphQLEnum<GitLabAPI.CiJobStatus>? { __data["status"] }
                /// Duration of the job in seconds.
                public var duration: Int? { __data["duration"] }
                /// When the job was started.
                public var startedAt: GitLabAPI.Time? { __data["startedAt"] }
                /// When a job has finished running.
                public var finishedAt: GitLabAPI.Time? { __data["finishedAt"] }
                /// Message on why the job failed.
                public var failureMessage: String? { __data["failureMessage"] }
                /// Whether the job is allowed to fail.
                public var allowFailure: Bool { __data["allowFailure"] }
                /// Artifacts generated by the job.
                public var artifacts: Artifacts? { __data["artifacts"] }

                /// Project.Pipeline.Stages.Node.Jobs.Node.Artifacts
                ///
                /// Parent Type: `CiJobArtifactConnection`
                nonisolated public struct Artifacts: GitLabAPI.SelectionSet {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.CiJobArtifactConnection }
                  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("nodes", [Node?]?.self),
                  ] }
                  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                    PipelineDetailQuery.Data.Project.Pipeline.Stages.Node.Jobs.Node.Artifacts.self
                  ] }

                  /// A list of nodes.
                  public var nodes: [Node?]? { __data["nodes"] }

                  /// Project.Pipeline.Stages.Node.Jobs.Node.Artifacts.Node
                  ///
                  /// Parent Type: `CiJobArtifact`
                  nonisolated public struct Node: GitLabAPI.SelectionSet {
                    @_spi(Unsafe) public let __data: DataDict
                    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.CiJobArtifact }
                    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                      .field("__typename", String.self),
                      .field("name", String?.self),
                      .field("size", GitLabAPI.BigInt.self),
                      .field("fileType", GraphQLEnum<GitLabAPI.JobArtifactFileType>?.self),
                    ] }
                    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                      PipelineDetailQuery.Data.Project.Pipeline.Stages.Node.Jobs.Node.Artifacts.Node.self
                    ] }

                    /// File name of the artifact.
                    public var name: String? { __data["name"] }
                    /// Size of the artifact in bytes.
                    public var size: GitLabAPI.BigInt { __data["size"] }
                    /// File type of the artifact.
                    public var fileType: GraphQLEnum<GitLabAPI.JobArtifactFileType>? { __data["fileType"] }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
