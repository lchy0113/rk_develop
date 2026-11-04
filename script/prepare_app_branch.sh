#!/bin/bash
# Run from anywhere: always operate on vendor/kdiwin/apps/.

set -u

cd "$(dirname "$(readlink -f "$0")")" || exit 1

readonly BRANCH="${1:-master}"
result=0

disable_lfs_hook_file() {
    local hook="$1"
    local disabled_hook

    [[ -f "$hook" ]] || return 0
    grep -Eq 'git([ -])lfs|git lfs' "$hook" || return 0

    disabled_hook="${hook}.disabled"
    if [[ -e "$disabled_hook" ]]; then
        disabled_hook="${hook}.disabled.$(date +%Y%m%d%H%M%S)"
    fi

    mv -- "$hook" "$disabled_hook"
    echo "-- disabled unused Git LFS hook: $hook"
}

disable_lfs_hooks() {
    local app="$1"
    local git_dir="$2"
    local configured_hooks_path
    local effective_hook
    local hook

    # core.hooksPath or repo worktrees can place the effective hook outside
    # the directory returned by --absolute-git-dir. Check it explicitly.
    effective_hook="$(git -C "$app" rev-parse --git-path hooks/post-checkout)" || return 1
    if [[ "$effective_hook" != /* ]]; then
        effective_hook="$(readlink -m "$app/$effective_hook")"
    fi
    disable_lfs_hook_file "$effective_hook"

    configured_hooks_path="$(git -C "$app" config --path --get core.hooksPath || true)"
    if [[ -n "$configured_hooks_path" ]]; then
        if [[ "$configured_hooks_path" != /* ]]; then
            configured_hooks_path="$(readlink -m "$app/$configured_hooks_path")"
        fi
        disable_lfs_hook_file "$configured_hooks_path/post-checkout"
    fi

    [[ -d "$git_dir" ]] || return 0

    while IFS= read -r -d '' hook; do
        [[ "$hook" == "$effective_hook" ]] && continue
        disable_lfs_hook_file "$hook"
    done < <(find "$git_dir" -type f -path '*/hooks/post-checkout' -print0)
}

check_submodules() {
    local app="$1"
    local status

    status="$(git -C "$app" submodule status --recursive)" || return 1
    if printf '%s\n' "$status" | grep -Eq '^[+-U]'; then
        printf '%s\n' "$status" >&2
        return 1
    fi
}

while IFS= read -r -d '' kd_apps; do
    if ! git -C "$kd_apps" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        continue
    fi

    echo "[$kd_apps]"

    app_git_dir="$(git -C "$kd_apps" rev-parse --absolute-git-dir)" || {
        echo "XX invalid Git repository: $kd_apps" >&2
        result=1
        continue
    }

    # These projects do not use Git LFS. Disable stale hooks before checkout,
    # including hooks stored in already initialized nested submodules.
    disable_lfs_hooks "$kd_apps" "$app_git_dir"

    if ! git -C "$kd_apps" checkout "$BRANCH"; then
        echo "XX checkout failed: $kd_apps ($BRANCH)" >&2
        result=1
        continue
    fi

    git -C "$kd_apps" branch --set-upstream-to="apps/$BRANCH" "$BRANCH" \
        2>/dev/null || true

    if ! git -C "$kd_apps" pull; then
        echo "XX pull failed: $kd_apps" >&2
        result=1
        continue
    fi

    [[ -f "$kd_apps/.gitmodules" ]] || continue

    git -C "$kd_apps" submodule sync --recursive
    if ! git -C "$kd_apps" submodule update --init --recursive; then
        # Repair interrupted or relocated submodules whose .git file points to
        # missing metadata. Local submodule worktrees are intentionally reset.
        echo "!! repair submodule: $kd_apps"
        git -C "$kd_apps" submodule deinit -f --all || true

        modules_dir="${app_git_dir}/modules"
        if [[ -d "$modules_dir" ]]; then
            rm -rf -- "$modules_dir"
        fi

        git -C "$kd_apps" submodule sync --recursive
        if ! git -C "$kd_apps" submodule update --init --recursive; then
            echo "XX submodule update failed: $kd_apps" >&2
            result=1
            continue
        fi
    fi

    # A freshly initialized repository should not contain an LFS hook, but
    # enforce the no-LFS policy before the Android build runs with --force.
    disable_lfs_hooks "$kd_apps" "$app_git_dir"

    if ! check_submodules "$kd_apps"; then
        echo "XX submodule verification failed: $kd_apps" >&2
        result=1
    fi
done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)

exit "$result"
