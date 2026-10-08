// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

nonisolated public enum CiJobStatus: String, EnumType {
  /// A job that is created.
  case created = "CREATED"
  /// A job that is waiting for resource.
  case waitingForResource = "WAITING_FOR_RESOURCE"
  /// A job that is preparing.
  case preparing = "PREPARING"
  /// A job that is waiting for callback.
  case waitingForCallback = "WAITING_FOR_CALLBACK"
  /// A job that is pending.
  case pending = "PENDING"
  /// A job that is running.
  case running = "RUNNING"
  /// A job that is success.
  case success = "SUCCESS"
  /// A job that is failed.
  case failed = "FAILED"
  /// A job that is canceling.
  case canceling = "CANCELING"
  /// A job that is canceled.
  case canceled = "CANCELED"
  /// A job that is skipped.
  case skipped = "SKIPPED"
  /// A job that is manual.
  case manual = "MANUAL"
  /// A job that is scheduled.
  case scheduled = "SCHEDULED"
}
