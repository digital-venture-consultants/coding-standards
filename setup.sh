#!/bin/bash

set -ux

usage() {
    cat 1>&2 <<EOF
coding standards installer

USAGE:
    coding-standards [FLAGS] [OPTIONS]

FLAGS:
    -v, --verbose           Enable verbose output # TODO!
    -q, --quiet             Disable progress output # TODO!
    -y                      Disable confirmation prompt. # TODO!
        --no-modify-path    Don't configure the PATH environment variable # TODO!
    -h, --help              Prints help information # TODO!
    -V, --version           Prints version information # TODO!

OPTIONS:
        --default-host <default-host>              Choose a default host triple # TODO!
        --default-toolchain <default-toolchain>    Choose a default toolchain to install # TODO!
        --default-toolchain none                   Do not install any toolchains # TODO!
        --profile [minimal|default|complete]       Choose a profile # TODO!
    -c, --component <components>...                Component name to also install # TODO!
    -t, --target <targets>...                      Target name to also install # TODO!
EOF
}

main() {
  destPath=${@:-/tmp}

  preCommitFileUrl="https://raw.githubusercontent.com/fabiodvc/coding-standards/main/.pre-commit-config.yaml"
  eslintFileUrl="https://raw.githubusercontent.com/fabiodvc/coding-standards/main/.eslint.yaml"
  # todo...

  ensure downloader "$preCommitFileUrl" "$destPath/"
  ensure downloader "$eslintFileUrl" "$destPath/"

  say "..."

  ensure "cd $destPath/ && pip3 install pre-commit && pre-commit"
  ensure "cd $destPath/ && npm install && npm run build"

  say "..."

  say "# TODO!"
}

say() {
  printf 'codingstandards: %s\n' "$1"
}

err() {
  say "$1" >&2
  exit 1
}

need_cmd() {
  if ! check_cmd "$1"; then
    err "need '$1' (command not found)"
  fi
}

check_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Run a command that should never fail. If the command fails execution
# will immediately terminate with an error showing the failing
# command.
ensure() {
    if ! "$@"; then err "command failed: $*"; fi
}

# This wraps curl or wget. Try curl first, if not installed,
# use wget instead.
downloader() {
    local _dld
    local _ciphersuites
    local _err
    local _status
    if check_cmd curl; then
        _dld=curl
    elif check_cmd wget; then
        _dld=wget
    else
        _dld='curl or wget' # to be used in error message of need_cmd
    fi

    if [ "$1" = --check ]; then
        need_cmd "$_dld"
    elif [ "$_dld" = curl ]; then
        get_ciphersuites_for_curl
        _ciphersuites="$RETVAL"
        if [ -n "$_ciphersuites" ]; then
            _err=$(curl --proto '=https' --tlsv1.2 --ciphers "$_ciphersuites" --silent --show-error --fail --location "$1" --output "$2" 2>&1)
            _status=$?
        else
            echo "Warning: Not enforcing strong cipher suites for TLS, this is potentially less secure"
            if ! check_help_for "$3" curl --proto --tlsv1.2; then
                echo "Warning: Not enforcing TLS v1.2, this is potentially less secure"
                _err=$(curl --silent --show-error --fail --location "$1" --output "$2" 2>&1)
                _status=$?
            else
                _err=$(curl --proto '=https' --tlsv1.2 --silent --show-error --fail --location "$1" --output "$2" 2>&1)
                _status=$?
            fi
        fi
        if [ -n "$_err" ]; then
            echo "$_err" >&2
            if echo "$_err" | grep -q 404$; then
                err "installer for platform '$3' not found, this may be unsupported"
            fi
        fi
        return $_status
    elif [ "$_dld" = wget ]; then
        get_ciphersuites_for_wget
        _ciphersuites="$RETVAL"
        if [ -n "$_ciphersuites" ]; then
            _err=$(wget --https-only --secure-protocol=TLSv1_2 --ciphers "$_ciphersuites" "$1" -O "$2" 2>&1)
            _status=$?
        else
            echo "Warning: Not enforcing strong cipher suites for TLS, this is potentially less secure"
            if ! check_help_for "$3" wget --https-only --secure-protocol; then
                echo "Warning: Not enforcing TLS v1.2, this is potentially less secure"
                _err=$(wget "$1" -O "$2" 2>&1)
                _status=$?
            else
                _err=$(wget --https-only --secure-protocol=TLSv1_2 "$1" -O "$2" 2>&1)
                _status=$?
            fi
        fi
        if [ -n "$_err" ]; then
            echo "$_err" >&2
            if echo "$_err" | grep -q ' 404 Not Found$'; then
                err "installer for platform '$3' not found, this may be unsupported"
            fi
        fi
        return $_status
    else
        err "Unknown downloader"   # should not reach here
    fi
}

main "$@" || exit 1
