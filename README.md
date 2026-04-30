# Debian Packaging Template

This repository contains GitHub Action templates to automate packaging upstream GitHub repositories into Debian (`.deb`) packages. It can package from pre-compiled binaries or by compiling from source, and includes a cron job to automatically check for new releases and trigger a build.

## How to use this Template Repository (Recommended Approach)

The easiest and cleanest way to manage multiple packages is to treat this repository as a **Template**. You will create one repository per package you want to maintain.

1. **Create a new repository** from this template (e.g., `deb-fzf`, `deb-bat`).
2. Edit `package.env` to configure the target repository, package name, maintainer, and license.
3. Edit `scripts/package_binary.sh` (or `scripts/build_source.sh` if compiling from source) to specify exactly how to download the binary or build the source for the specific package.
4. Go to **Actions -> General -> Workflow permissions** in your GitHub repository settings and ensure "Read and write permissions" are enabled, allowing the action to create Releases.
5. The `Check Upstream Release` workflow runs daily. If a new version is detected on the upstream repository, it automatically triggers the `Build and Release` workflow.

### Pros of the Template Approach
* **Clean Releases Page**: Your GitHub releases page directly correlates to `.deb` package releases.
* **Isolated failures**: If one package build fails or changes its release archive naming scheme, it doesn't affect your other packages.
* **Simple Actions**: No complex matrix logic needed to handle different repositories in a single file.

---

## Alternative: Monorepo Approach

If you prefer to manage dozens of packages in a single repository without cluttering your GitHub account, you can convert this setup into a **Monorepo**.

### How to structure a Monorepo
Instead of editing a root `package.env`, you would restructure the repo to have a folder per package:
```
packages/
  fzf/
    package.env
    package_binary.sh
  bat/
    package.env
    package_binary.sh
```

### Modifying the Actions for a Monorepo
1. **Update Check Release workflow**: You would write a Python or Bash script that loops over all directories in `packages/`, checks their upstream version, and triggers the build workflow passing both `package_name` and `version` as inputs.
2. **Update Build workflow**: The `build-binary.yml` would accept a `package_name` input, `cd` into `packages/${{ inputs.package_name }}`, and run the scripts from there.
3. **Tagging and Releases**: GitHub releases would need to be prefixed (e.g., `fzf-v1.0.0` and `bat-v2.0.0`), and your release action must be configured to generate these composite tags.

### Pros and Cons of Monorepo
* **Pros**: Centralized management. One cron job checks all packages. Less repository sprawl.
* **Cons**: The "Releases" tab becomes a mix of all software. Workflows become slightly more complex (passing package names around, handling matrix builds dynamically).

---

## Workflows Included

* **`.github/workflows/check-upstream.yml`**: Runs via cron daily. Compares the latest tag of the upstream repository with the latest tag of this repository. Triggers a build if a new version is found.
* **`.github/workflows/build-binary.yml`**: Manually triggered (or triggered by the checker). Downloads pre-compiled binaries, wraps them in a Debian package structure, and publishes a GitHub Release with the `.deb` attached.
* **`.github/workflows/build-source.yml`**: Same as above, but clones the source code and compiles it first.

## Customizing the Scripts

Make sure to look at the `TEMPLATE SECTION` inside `scripts/package_binary.sh` and `scripts/build_source.sh`. Every upstream project uses slightly different naming conventions for their release archives (e.g., `fzf-1.0.0-linux-amd64.tar.gz` vs `bat-v1.0.0-x86_64-unknown-linux-gnu.tar.gz`). You must customize the `wget` or `curl` command to match the upstream project's exact URLs.
