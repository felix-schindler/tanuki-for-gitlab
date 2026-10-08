// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

nonisolated public enum JobArtifactFileType: String, EnumType {
  /// ARCHIVE job artifact file type.
  case archive = "ARCHIVE"
  /// METADATA job artifact file type.
  case metadata = "METADATA"
  /// TRACE job artifact file type.
  case trace = "TRACE"
  /// JUNIT job artifact file type.
  case junit = "JUNIT"
  /// METRICS job artifact file type.
  case metrics = "METRICS"
  /// METRICS REFEREE job artifact file type.
  case metricsReferee = "METRICS_REFEREE"
  /// NETWORK REFEREE job artifact file type.
  case networkReferee = "NETWORK_REFEREE"
  /// DOTENV job artifact file type.
  case dotenv = "DOTENV"
  /// COBERTURA job artifact file type.
  case cobertura = "COBERTURA"
  /// JACOCO job artifact file type.
  case jacoco = "JACOCO"
  /// CLUSTER APPLICATIONS job artifact file type.
  case clusterApplications = "CLUSTER_APPLICATIONS"
  /// LSIF job artifact file type.
  case lsif = "LSIF"
  /// CYCLONEDX job artifact file type.
  case cyclonedx = "CYCLONEDX"
  /// ANNOTATIONS job artifact file type.
  case annotations = "ANNOTATIONS"
  /// REPOSITORY XRAY job artifact file type.
  case repositoryXray = "REPOSITORY_XRAY"
  /// SAST job artifact file type.
  case sast = "SAST"
  /// SECRET DETECTION job artifact file type.
  case secretDetection = "SECRET_DETECTION"
  /// DEPENDENCY SCANNING job artifact file type.
  case dependencyScanning = "DEPENDENCY_SCANNING"
  /// CONTAINER SCANNING job artifact file type.
  case containerScanning = "CONTAINER_SCANNING"
  /// CLUSTER IMAGE SCANNING job artifact file type.
  case clusterImageScanning = "CLUSTER_IMAGE_SCANNING"
  /// DAST job artifact file type.
  case dast = "DAST"
  /// LICENSE SCANNING job artifact file type.
  case licenseScanning = "LICENSE_SCANNING"
  /// ACCESSIBILITY job artifact file type.
  case accessibility = "ACCESSIBILITY"
  /// CODE QUALITY job artifact file type.
  case codequality = "CODEQUALITY"
  /// PERFORMANCE job artifact file type.
  case performance = "PERFORMANCE"
  /// BROWSER PERFORMANCE job artifact file type.
  case browserPerformance = "BROWSER_PERFORMANCE"
  /// LOAD PERFORMANCE job artifact file type.
  case loadPerformance = "LOAD_PERFORMANCE"
  /// TERRAFORM job artifact file type.
  case terraform = "TERRAFORM"
  /// REQUIREMENTS job artifact file type.
  case requirements = "REQUIREMENTS"
  /// REQUIREMENTS V2 job artifact file type.
  case requirementsV2 = "REQUIREMENTS_V2"
  /// COVERAGE FUZZING job artifact file type.
  case coverageFuzzing = "COVERAGE_FUZZING"
  /// API FUZZING job artifact file type.
  case apiFuzzing = "API_FUZZING"
}
