# Tanuki

This is my [GitLab App](https://gitlab.com/felix-schindler/gitlab-ios),
reimagined with the power of GraphQL.

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
2. Add changelog in `changelogs/v<verison>.md`
3. Tag branch `git push origin v<version>`

Pushing the tag triggers `.github/workflows/release.yml` +
`.gitea/workflows/release.yml`, which create releases with the body from
`changelogs/v<version>.md`.

# Feature comparison

| Feature                          | Tanuki | Gitblur | Gitblur Pro |
| -------------------------------- | ------ | ------- | ----------- |
| Price                            | 0,99€  | Free    | 69,99€      |
| **Projects**                     |        |         |             |
| Browsing                         | ✅     | ✅      | ✅          |
| Search and Filtering             | ✅     | ✅      | ✅          |
| Star and Fork                    | Star ✅, Fork ❌ | ✅      | ✅          |
| Wiki browsing                    | ❌     | ✅      | ✅          |
| Share                            | ✅     | ✅      | ✅          |
| Create Project                   | ✅     | ❌      | ✅          |
| Project Settings                 | ❌     | ❌      | ✅          |
| Project Download                 | ❌     | ❌      | ✅          |
| CI/CD                            | ✅ (view only) | ❌      | ✅          |
| Invite Member                    | ✅     | ❌      | ✅          |
| Invite Group                     | ❌     | ❌      | ✅          |
| Wiki Management                  | ❌     | ❌      | ✅          |
| Create Snippet                   | ❌     | ❌      | ✅          |
| **Repository**                   |        |         |             |
| Tree Browsing                    | ✅     | ✅      | ✅          |
| Showing Changed Files            | ✅     | ✅      | ✅          |
| Source Code Browsing             | ✅     | ❌      | ✅          |
| Code Editor                      | ❌     | ❌      | ✅          |
| Create File, Branch, Tag         | ❌     | ❌      | ✅          |
| Import, Export Files             | ❌     | ❌      | ✅          |
| **Merge Requests**               |        |         |             |
| Browsing                         | ✅     | ✅      | ✅          |
| Search and Filter                | ✅     | ✅      | ✅          |
| Emoji Reaction                   | ❌     | ✅      | ✅          |
| Create, Delete, Close, Edit      | Close, Delete ✅; Create, Edit ❌ | ❌      | ✅          |
| Merge Action                     | ✅     | ❌      | ✅          |
| Mark as Draft                    | ❌     | ❌      | ✅          |
| Add Comments (supports Markdown) | ✅     | ❌      | ✅          |
| **Issues**                       |        |         |             |
| Browsing                         | ✅     | ✅      | ✅          |
| Search and Filter                | ✅     | ✅      | ✅          |
| Create, Delete, Close, Edit      | Create, Close, Delete ✅; Edit ❌ | ❌      | ✅          |
| Add Comments (supports Markdown) | ✅     | ❌      | ✅          |
| **Groups**                       |        |         |             |
| Browsing                         | ✅     | ✅      | ✅          |
| Create Group                     | ❌     | ❌      | ✅          |
| Create Project                   | ✅     | ❌      | ✅          |
| Create Subgroup                  | ❌     | ❌      | ✅          |
| Group Settings                   | ❌     | ❌      | ✅          |
| **Others**                       |        |         |             |
| Todo Browsing                    | ✅     | ✅      | ✅          |
| Keys Browsing                    | ❌     | ✅      | ✅          |
| Email Management                 | ❌     | ✅      | ✅          |
| Keys Management                  | ❌     | ✅      | ✅          |
| Todo Management                  | ❌     | ❌      | ✅          |
| Multi Account                    | ✅     | ❌      | ✅          |
| View in Browser                  | ❌     | ❌      | ✅          |
| Push Notifications               | ❌     | ❌      | ✅          |
