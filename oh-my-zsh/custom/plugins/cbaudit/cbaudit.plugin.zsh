# This collection of commands can give a small overview over a new codebase by
# looking at the git history.
# Based on the commands by Ally Piechowski
# https://piechowski.io/post/git-commands-before-reading-code/
cbaudit() {
    echo <<"EOF"
# What files change the most
$(git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20)

# Who built this
$(git shortlog -sn --no-merges)

# Where do bugs cluster
$(git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20)

# Accelerating or Dying
$(git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c)

# How often is firefighting
$(git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback')

EOF
}
