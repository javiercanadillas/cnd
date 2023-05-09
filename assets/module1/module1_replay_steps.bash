#!/usr/bin/env bash
## Prevent this script from being sourced
#shellcheck disable=SC2317
return 0  2>/dev/null || :

# shellcheck disable=SC2128
script_name=$(basename "$0")
#shellcheck disable=SC2128,SC2034
script_dir=$(dirname "$(readlink --canonicalize --no-newline "$0")")
source "$script_dir/../common/common_bash_libs"

# Check that cloudshell bootstrap has been done
check_cloudshell_bootstrap() {
  [[ -f "$HOME/.config/cnd/.cloudshell_bootstrap.done" ]] || { error "Cloudshell bootstrap execution has not been properly registered. Aborting." && exit 1; }
}

create_basic_structure() {
  # Set the workdir at the git repo base level
  workdir="$script_dir/../.."
  echo "export WORKDIR=\"$workdir\"" >> "$HOME/.labenv_custom.bash" 
}

install_pyenv() {
  info "Installing pyenv..."
  curl https://pyenv.run | bash > /dev/null 2>&1
  cat << "EOF" >> "$HOME/.labenv_custom.bash"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
}

install_rye() {
  info "Installing rye..."
  curl https://sh.rustup.rs -sSf | sh
  #shellcheck disable=SC1091
  "$HOME/.cargo/bin/cargo" install --git https://github.com/mitsuhiko/rye rye
}

# Setup myfirstapp dir structure
set_myfirstapp_structure() {
  local -r app_workdir="$WORKDIR/myfirstapp/src"
  info "Creating the folder structure under $app_workdir"
  if [[ -z $WORKDIR ]]; then
    error "\$WORKDIR is not set, make sure you've run $HOME/assets/common/bootstrap.bash before running this script"
    exit 1
  else
    mkdir -p "$app_workdir"
  fi
}

# Setup python environment
set_python_environment() {
  info "Setting up python environment..."
  
  info "Installing Python 3.11.3 and setting it as global..."
  warning "This may take a while..."
  pyenv install 3.11.3
  pyenv global 3.11.3
  pushd "$WORKDIR/myfirstapp" || { error "Failed to move to dir $WORKDIR/myfirstapp. Exiting"; exit 1; }
  
  info "Creating virtual environment in $WORKDIR/myfirstapp..."
  python -m venv .venv
  #shellcheck disable=SC1091
  source ".venv/bin/activate"
  
  info "Upgrading pip..."
  python -m pip install --upgrade pip
  
  info "Installing and registering dependencies..."
  pip install flask
  pip freeze > requirements.txt
  cp "$WORKDIR/assets/module1/main.py" "$WORKDIR/myfirstapp/src" || { error "Failed to copy main.py to $WORKDIR/myfirstapp/src. Exiting"; exit 1; }
  popd || exit 1
}

wrap_up() {
  info "Registering successful replay of module 1 steps..."
  local -r registry_dir="$HOME/.config/cnd"
  mkdir -p "$registry_dir"
  touch "$registry_dir/.module1_steps.done"
  printfx "--------------------------------------------------------"
  warning "You must run \"source \$HOME/.bashrc\" before continuing"
  printfx "--------------------------------------------------------"
}

main() {
  info "Bootstrapping basic Cloud Shell configuration..."
  "$script_dir/../common/cloudshell_bootstrap.bash"
  check_cloudshell_bootstrap
  create_basic_structure
  install_pyenv
  # Undocumented option to automatically install Rye
  [[ $1 == "rye" ]] && install_rye
  info "Sourcing custom changes to the environment..."
  #shellcheck disable=SC1091
  source "$HOME/.labenv_custom.bash"
  set_myfirstapp_structure
  set_python_environment
  wrap_up
}

main "$@"