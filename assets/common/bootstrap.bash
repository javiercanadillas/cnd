#!/usr/bin/env bash
## Prevent this script from being sourced
#shellcheck disable=SC2317
return 0  2>/dev/null || :

source "./common_bash_libs"

# Configures a basic working Cloud Shell environment for Qwiklabs
configure_qw_cs() {
  local -r cs_source="https://raw.githubusercontent.com/javiercanadillas/qwiklabs-cloudshell-setup/main/setup_qw_cs"
  bash <(curl -s "$cs_source")
}

create_basic_structure() {
  # Set the workdir at the git repo base level
  workdir="$script_dir/../.."
  echo "export WORKDIR=\"$workdir\"" >> "$HOME/.labenv_custom.bash" 
}

install_pyenv() {
  info "Installing pyenv..."
  curl https://pyenv.run | bash
  cat << "EOF" >> "$HOME/.labenv_custom.bash"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
}

set_git_config() {
  info "Setting git config..."
  git config --global user.name "$USER" # env var containing the Qwiklabs user ID
  git config --global user.email "$USER@qwiklabs.net"
  git config --global init.defaultBranch main
}

install_rye() {
  info "Installing rye..."
  curl https://sh.rustup.rs -sSf | sh
  #shellcheck disable=SC1091
  source "$HOME/.bashrc"
  cargo install --git https://github.com/mitsuhiko/rye rye
}

wrap_up() {
  info "Registering successful bootstraping of module 1..."
  local -r registry_dir="$HOME/.config/cnd"
  mkdir -p "$registry_dir"
  touch "$registry_dir/.module1_bootstrap.done"
  echo    "--------------------------------------------------------"
  warning "You must run \"source \$HOME/.bashrc\" before continuing"
  echo    "--------------------------------------------------------"
}

main() {
  check_basic_requirements
  create_basic_structure
  install_pyenv
  set_git_config
  # Undocumented option to automatically install Rye
  [[ $1 == "rye" ]] && install_rye
  wrap_up
}

main "$@"