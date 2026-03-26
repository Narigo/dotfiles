# Adds a function to create a password and copies it to clipboard
DEFAULT_PW2CB_PW_LENGTH=24

_pw2cb_copy() {
    if command -v pbcopy &>/dev/null; then
        pbcopy
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard
    else
        # OSC 52: asks the terminal to set the clipboard directly
        local data
        data=$(base64)
        printf '\e]52;c;%s\a' "$data"
    fi
}

pw2cb() {
    local pwlen="${1:-$DEFAULT_PW2CB_PW_LENGTH}"
    local pw
    pw=$(openssl rand -out /dev/stdout "$pwlen" | base64 | tr -- '+/' '-_' | tr -d '=' | tr -d '\n')
    echo -n "$pw" | _pw2cb_copy
    echo "Password copied to clipboard ($pwlen bytes)"
}
