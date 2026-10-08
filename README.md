# Tanuki

This is my [GitLab App](https://gitlab.com/felix-schindler/gitlab-ios),
reimagined with the power of GraphQL.

A native SwiftUI GitLab client for iOS, with a companion
watch app. It works with gitlab.com and self-hosted instances, and
supports multiple accounts. Most screens are backed by GraphQL (Apollo, cached
to a local SQLite database); anything GraphQL does not expose (files, wikis,
job traces, archive downloads, …) goes through REST with the same token.

## Supported features

### Accounts and authentication

- Sign in with OAuth (`AuthenticationServices`) or a personal access token.
- Multiple instances / accounts, switchable at any time; the selected instance
  is synced to the Apple Watch.
- Automatic token refresh, cookie handling for the Markdown web view, and a
  per-instance GraphQL cache reset on switch.

### Projects

- Browse your projects, starred projects, group projects and other users'
  projects (Explore tab), with search and filters (membership, access level,
  archived/active, marked for deletion).
- Project overview: description, visibility, topics, star and fork counts,
  language chart, README / LICENSE / CONTRIBUTING rendering, open issue and
  merge request counts, repository size, commit count, release and label
  counts, plus the last commit.
- Star and fork (when permitted), share a link, copy the HTTPS/SSH clone URLs,
  request access, and download `archive.zip`.
- Create a project (also inside a group), and edit its name, description and
  visibility.
- Invite members with a role and optional expiry date, and share the project
  with a group.
- Pipelines: list and detail with stages and jobs, job trace logs, artifact
  download, and retry / cancel / play on individual jobs.
- Releases: browse and create.
- Labels: browse and create. Milestones: browse, filter and create.
- Wiki: read-only page browsing when the project wiki is enabled.
- Project activity feed.

### Repository

- Browse the file tree and view text source files with syntax highlighting.
- Rich previews for images, video/audio and PDF instead of raw text, with a
  download button, progress bar and share sheet for large or binary files.
- Commits: list, detail, and commit signature verification display.
- Create files, branches and tags.

### Merge requests

- Browse project, group and user merge requests (assigned, authored, review
  requested) with search and filters.
- Detail view: description, state, source/target branch, reviewers, approvals,
  changed-files overview (diff), commit list, and comments.
- Create, edit title/description, close/reopen and delete.
- Mark as draft / ready.
- Merge with options (auto-merge, squash + squash message, remove source
  branch, commit message, SHA guard) and a detailed merge-status display.
- Approve / revoke approval and up/down vote.
- Add comments with Markdown (raw HTML rendering is an opt-in setting).

### Issues

- Browse project, group and user issues with search and filters; detail view
  with assignees, labels, milestone and comments.
- Create, edit title/description, close/reopen, delete, up/down vote and
  comment (Markdown).

### Groups

- Browse your groups and all available groups; group detail with projects,
  descendant groups, members, labels, milestones and merge requests.
- Create groups and subgroups, and create projects inside a group.
- Edit group name, description and visibility.
- Manage members, and view the group activity feed, timelogs and custom emojis.

### Todos, snippets, users and more

- Todos: browse your todos and other users' todos, mark them done by swiping.
- Snippets: browse your snippets and other users' snippets, view files and
  clone URLs, and create personal snippets.
- Users: explore users; profiles show the contribution heatmap, status, issues,
  groups, projects, starred projects, snippets, activity, timelogs and todos.
  You can also create a status.
- "Jump": paste a GitLab URL (including work item links) from the clipboard to
  deep-link straight to the project, issue or merge request.
- In-app toasts and haptic feedback for actions.

### Apple Watch app

- Uses the instance configured on the iPhone (synced through the app group).
- Browse your issues and your merge requests (assigned, authored, review
  requested).

### Settings

- Cache management (HTTP cache and temporary files), cookie management (web
  login used for HTML rendering), and instance management.
- Toggle raw-HTML rendering in Markdown, send feedback, and rate the app.

## Not supported (yet)

- Push notifications.
- Opening entities in the browser (links can be shared or copied, but the app
  does not launch Safari).
- Emoji reactions, other than the 👍/👎 votes on issues and merge requests
  (comments can't be reacted to, and a vote can't be removed once given).
- Editing or deleting existing comments, and editing existing repository files
  (files, branches and tags can only be created, not modified or deleted).
- Uploading/importing files into a repository.
- Wiki editing/management, and project snippets (personal snippets only).
- SSH key and email management (browsing only).
- Running a new pipeline (existing jobs can be retried, cancelled or played).

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
| Email Management                 | Browse ✅, Manage ❌ | ✅      | ✅          |
| Keys Management                  | Browse ✅, Manage ❌ | ✅      | ✅          |
| Todo Management                  | ✅ (mark as done) | ❌      | ✅          |
| Multi Account                    | ✅     | ❌      | ✅          |
| View in Browser                  | ❌     | ❌      | ✅          |
| Push Notifications               | ❌     | ❌      | ✅          |
