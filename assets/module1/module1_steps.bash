#!/usr/bin/env bash
## Prevent this script from being sourced
#shellcheck disable=SC2317
return 0  2>/dev/null || :

source "../common/common_bash_libs"

# Check that the basic requirements have been met
check_basic_requirements() {
  [[ -f "$HOME/.config/cnd/.module1_bootstrap.done" ]] || { error "Module 1 has not been bootstrapped, exiting"; return 1; }
}



main() {
  check_basic_requirements
}

main "$@"