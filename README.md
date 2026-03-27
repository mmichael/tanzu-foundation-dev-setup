# Tanzu Foundation Dev Setup

Scripts for provisioning a Tanzu Application Service (TAS) foundation with buildpacks, orgs, spaces, and sample apps for development and testing purposes.

## Prerequisites

- Bash 3.2.57 or later (the default shell on macOS)
- [`cf` CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html) installed and authenticated against a TAS foundation
- [`jq`](https://jqlang.github.io/jq/) installed
- `git` installed
- Already logged in via `cf login` before running any script

## Repository Layout

```
.
├── buildpacks/       # Cached buildpack zip files to be uploaded
├── repos/            # Cloned repositories (created at runtime)
└── scripts/          # Setup and teardown scripts
```

## Environment Variables

These variables control the resources created. They can be set before running any script to avoid being prompted:

| Variable | Description | Example |
|---|---|---|
| `CF_ORG` | Org name to create and target | `acme-org` |
| `CF_SPACE` | Space name to create and target | `dev` |
| `APP_PREFIX` | Optional prefix for app names | `test` → `test-go-app`; empty → `go-app` |

If any variable is not set, `setup.sh` will prompt for it interactively.

## Scripts

### `setup.sh` — Full setup (recommended entry point)

Runs all setup steps in order. Prompts for `CF_ORG`, `CF_SPACE`, and `APP_PREFIX` if they are not already set in the environment. `APP_PREFIX` is optional — press Enter to skip it and apps will be named without a prefix.

```bash
# Interactive
bash scripts/setup.sh

# Non-interactive (pass variables via environment)
CF_ORG=acme-org CF_SPACE=dev APP_PREFIX=test bash scripts/setup.sh
```

Steps performed:
1. Clones required repositories
2. Uploads buildpacks from the `buildpacks/` directory
3. Creates orgs and spaces
4. Pushes sample apps

---

### `clone-repos.sh` — Clone required repositories

Clones [cf-acceptance-tests](https://github.com/cloudfoundry/cf-acceptance-tests) into `repos/cf-acceptance-tests`. Skips the clone if the directory already exists.

```bash
bash scripts/clone-repos.sh
```

---

### `create-buildpacks.sh` — Upload buildpacks

Iterates over all `.zip` files in the `buildpacks/` directory in reverse-alphabetical order and uploads each one as a custom buildpack, starting at position 30. You can add additional buildpack versions that you download from RMT locally. Each buildpack is assigned to the `cflinuxfs4` stack. Buildpacks that already exist on the foundation are skipped.


Naming convention applied to zip filenames:
- `-cached-cflinuxfs4` is stripped
- `.` is replaced with `_`

```bash
bash scripts/create-buildpacks.sh
```

---

### `create-orgs-and-spaces.sh` — Create org and space

Creates the org and space specified by `CF_ORG` and `CF_SPACE`, then targets them as the active target. Each resource is checked first and skipped if it already exists.

Requires `CF_ORG` and `CF_SPACE` to be set in the environment (handled automatically by `setup.sh`).

```bash
CF_ORG=acme-org CF_SPACE=dev bash scripts/create-orgs-and-spaces.sh
```

---

### `push-apps.sh` — Push sample apps

Pushes sample Go, Java Spring, Ruby, Node.js, Nginx, Python, PHP, and R applications from the cloned `cf-acceptance-tests` repo. Each app is checked against the foundation first; if an app with the same name already exists it is skipped.

Requires `APP_PREFIX` to be set in the environment (handled automatically by `setup.sh`).

Apps pushed:

| App name | Buildpack |
|---|---|
| `<APP_PREFIX>-go-app` | default |
| `<APP_PREFIX>-go-app-v1_10_64` | `go_buildpack-v1_10_64` |
| `<APP_PREFIX>-java-spring-app` | default |
| `<APP_PREFIX>-java-spring-app-v4_81_0` | `java-buildpack-offline-v4_81_0` |
| `<APP_PREFIX>-ruby-app` | default |
| `<APP_PREFIX>-node-app` | default |
| `<APP_PREFIX>-node-app-v1_8_65` | `nodejs_buildpack-v1_8_65` |
| `<APP_PREFIX>-nginx-app` | default |
| `<APP_PREFIX>-python-app` | default |
| `<APP_PREFIX>-php-app` | default |
| `<APP_PREFIX>-r-app` | default |

```bash
APP_PREFIX=test bash scripts/push-apps.sh
```

---

### `cleanup.sh` — Tear down resources

Deletes the org (and all spaces and apps within it) and removes all buildpacks that were uploaded from the `buildpacks/` directory.

Requires `CF_ORG` to be set in the environment.

```bash
CF_ORG=acme-org bash scripts/cleanup.sh
```
