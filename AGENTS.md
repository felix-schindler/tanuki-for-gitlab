# AGENTS.md — tanuki-ios

Native iOS GitLab client (SwiftUI, Swift 6.0). Xcode project, no unit tests.

## Build

- Open `Tanuki.xcodeproj` in Xcode. Targets: `Tanuki` (iOS app) + `Tanuki Watch App`.
- Or: `xcodebuild -project Tanuki.xcodeproj -scheme Tanuki -destination 'generic/platform=iOS Simulator' build`
- Swift packages resolve from network on first build (Alamofire, Apollo, swift-markdown-ui, etc.).

## Format / lint

- `make fmt` — format in place; `make lint` — check only (fails with finding count); `make check` — runs `fmt` then `lint`.
- Uses `swift format` with `{lineLength:120, tabs}`. Scope is `./Tanuki`, `./Tanuki Watch App`, `./Emoji` and `./Shared` — do not reformat `GitLabAPI/` (generated).

## GraphQL (Apollo iOS, `exact: 2.4.0` in `GitLabAPI/Package.swift`)

- Schema: `gitlab@current.graphqls`. Operations: `Tanuki/Queries/**/*.graphql`. Generated output: `GitLabAPI/Sources/` (separate SPM package, `GitLabAPI/Package.swift`).
- Regenerate: `./apollo-ios-cli fetch-schema` then `./apollo-ios-cli generate` (binary is gitignored; download Apollo CLI 2.4.0 if missing).
- Never hand-edit `GitLabAPI/Sources/`. To change an operation, edit the `.graphql` file and regenerate. Renovate ignores `apollographql/apollo-ios` (`renovate.json`) — do not bump it casually.

## Architecture

- Entry: `Tanuki/TanukiApp.swift` — `TabView` (Home / Todos / Explore / Profile), setup gate via `SessionStore.needsSetup`.
- `Tanuki/Core/Networking/API.swift` — REST via Alamofire (`@MainActor`, base `api/v4`, `convertFromSnakeCase`, ISO8601 with fractional seconds, `Authorization: Bearer`). Auth state in `InstanceManager` (multi-instance, app-group `UserDefaults("group.de.schindlerfelix.GitLab")` + legacy migration + Watch sync).
- `Tanuki/Core/Networking/Network.swift` — GraphQL via `Network.shared.apollo` (SQLite disk cache `tanuki_graphql_cache.sqlite`, Bearer interceptor). Call `resetApolloClient()` after instance switch; endpoint derives from `API.graphUrl`.
- `Tanuki/Queries/` + `Tanuki/Loaders/` — one domain per folder (Projects, Merge Requests, Issues, Groups, Users, Todos, …). Loaders are `*Loader.swift` SwiftUI views: async fetch → `LoadingView` / `FailedView` + `.refreshable`. Follow this pattern for new data views.
- `Tanuki/Views/{Auth,Entity-Specific,General,Settings}/`, `Tanuki/Forms/New*.swift` (create-forms), `Tanuki/Core/{Types,Utils,Notifications}/`.
- `Shared/Package.swift` is `TanukiShared`, shared by the app and watch targets (`AvatarImage`, `EmojiHelper` + `Resources/emoji.json`). The app itself is not SPM.

## Release

Bump `MARKETING_VERSION` in Xcode → add `changelogs/v<version>.md` → `git push origin v<version>`. Tag `v*` triggers `.github/workflows/release.yml`, which uses the changelog file as release body.
