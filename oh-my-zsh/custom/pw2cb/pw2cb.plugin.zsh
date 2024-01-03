# Adds a function to create a password and copies it to clipboard
DEFAULT_PW2CB_PW_LENGTH=24

pw2cb() {
    PWLEN="${1:-$DEFAULT_PW2CB_PW_LENGTH}"
    openssl rand -out /dev/stdout "$PWLEN" | base64 | tr -- '+/' '-_' | tr -d '=' | tr -d '\n' | pbcopy
}
