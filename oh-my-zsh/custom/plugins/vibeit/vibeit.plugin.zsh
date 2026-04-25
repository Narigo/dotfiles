# Pulls the viboilerplate scaffolding (.devcontainer, .claude, CLAUDE.md) into
# the current repo and commits it.
vibeit() {
    git fetch git@github.com:Narigo/viboilerplate.git main && \
    git checkout FETCH_HEAD -- .devcontainer .claude CLAUDE.md && \
    git add .devcontainer .claude CLAUDE.md && \
    git commit -sm "chore: Add viboilerplate"
}
