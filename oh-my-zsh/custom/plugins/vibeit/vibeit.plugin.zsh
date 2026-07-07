# Pulls the viboilerplate scaffolding (.devcontainer, .claude, CLAUDE.md,
# .gitignore) into the current repo and commits it. Initializes a git repo
# first if the current directory does not have one.
vibeit() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        git init || return
    fi

    git fetch git@github.com:Narigo/viboilerplate.git main || return
    git checkout FETCH_HEAD -- .devcontainer .claude CLAUDE.md || return

    if [[ -f .gitignore ]]; then
        local line
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ -n "$line" && "$line" != \#* ]] && ! grep -Fxq -- "$line" .gitignore; then
                printf '%s\n' "$line" >> .gitignore
            fi
        done < <(git show FETCH_HEAD:.gitignore)
    else
        git show FETCH_HEAD:.gitignore > .gitignore
    fi

    if read -q "REPLY?Set up the devcontainer from the host now? [y/N] "; then
        echo
        echo "Setting up the devcontainer from the host."
        .devcontainer/setup-on-host.sh
    else
        echo
        echo "Skipping devcontainer setup."
        return
    fi

    git add .devcontainer .claude CLAUDE.md .gitignore && \
    git commit -sm "chore: Add viboilerplate"
}
