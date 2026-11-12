# Tanuki

This is my [GitLab App](https://gitlab.com/felix-schindler/gitlab-ios),
reimagined with the power of GraphQL.

A native SwiftUI GitLab client for iOS, with a companion
watch app. It works with gitlab.com and self-hosted instances, and
supports multiple accounts. Most screens are backed by GraphQL (Apollo, cached
to a local SQLite database); anything GraphQL does not expose (files, wikis,
job traces, archive downloads, …) goes through REST with the same token.

## GraphQL

To fetch the latest schema and generate the API code, run:

```bash
make install-apollo-cli
make fetch-schema
make generate-apollo
```

## GitHub contributions

```
git remote add github git@github.com:felix-schindler/tanuki-for-gitlab.git
git fetch github pull/<id>/head:pr-<id>
```

# Release a new version

1. Change app version in Xcode → Targets → Tanuki → Identity → Version
2. Add changelog in `changelogs/v<version>.md`
3. Tag branch `git push origin v<version>`

Pushing the tag triggers `.github/workflows/release.yml` +
`.gitea/workflows/release.yml`, which create releases with the body from
`changelogs/v<version>.md`.

# Feature comparison

✅ = supported, ❌ = not supported, otherwise noted.

| Feature                          | Tanuki | Gitblur | Gitblur Pro |
| -------------------------------- | ------ | ------- | ----------- |
| Price                            | 0,99€  | Free    | 69,99€      |
| **Projects**                     |        |         |             |
| Browsing                         | ✅     | ✅      | ✅          |
| Search and Filtering             | ✅     | ✅      | ✅          |
| Star and Fork                    | ✅     | ✅      | ✅          |
| Wiki browsing                    | ✅     | ✅      | ✅          |
| Share                            | ✅     | ✅      | ✅          |
| Create Project                   | ✅     | ❌      | ✅          |
| Project Settings                 | ✅ (name, description, visibility) | ❌      | ✅          |
| Project Download                 | ✅     | ❌      | ✅          |
| CI/CD                            | ✅ (view, job logs/artifacts, retry/cancel/play) | ❌      | ✅          |
| Invite Member                    | ✅     | ❌      | ✅          |
| Invite Group                     | ✅     | ❌      | ✅          |
| Wiki Management                  | ❌     | ❌      | ✅          |
| Create Snippet                   | Personal ✅, Project ❌ | ❌      | ✅          |
| **Repository**                   |        |         |             |
| Tree Browsing                    | ✅     | ✅      | ✅          |
| Showing Changed Files            | ✅     | ✅      | ✅          |
| Source Code Browsing             | ✅     | ❌      | ✅          |
| Code Editor                      | ❌     | ❌      | ✅          |
| Create File, Branch, Tag         | ✅     | ❌      | ✅          |
| Import, Export Files             | Export ✅, Import ❌ | ❌      | ✅          |
| **Merge Requests**               |        |         |             |
| Browsing                         | ✅     | ✅      | ✅          |
| Search and Filter                | ✅     | ✅      | ✅          |
| Emoji Reaction                   | Vote 👍/👎 ✅, others ❌ | ✅      | ✅          |
| Create, Delete, Close, Edit      | ✅     | ❌      | ✅          |
| Merge Action                     | ✅     | ❌      | ✅          |
| Mark as Draft                    | ✅     | ❌      | ✅          |
| Add Comments (supports Markdown) | ✅     | ❌      | ✅          |
| **Issues**                       |        |         |             |
| Browsing                         | ✅     | ✅      | ✅          |
| Search and Filter                | ✅     | ✅      | ✅          |
| Create, Delete, Close, Edit      | ✅     | ❌      | ✅          |
| Add Comments (supports Markdown) | ✅     | ❌      | ✅          |
| **Groups**                       |        |         |             |
| Browsing                         | ✅     | ✅      | ✅          |
| Create Group                     | ✅     | ❌      | ✅          |
| Create Project                   | ✅     | ❌      | ✅          |
| Create Subgroup                  | ✅     | ❌      | ✅          |
| Group Settings                   | ✅ (name, description, visibility) | ❌      | ✅          |
| **Others**                       |        |         |             |
| Todo Browsing                    | ✅     | ✅      | ✅          |
| Keys Browsing                    | ✅     | ✅      | ✅          |
| Email Management                 | ✅     | ✅      | ✅          |
| Keys Management                  | ✅     | ✅      | ✅          |
| Todo Management                  | ✅ (mark as done) | ❌      | ✅          |
| Multi Account                    | ✅     | ❌      | ✅          |
| View in Browser                  | ✅ (via share button)     | ❌      | ✅          |
| Push Notifications               | ❌     | ❌      | ✅          |
