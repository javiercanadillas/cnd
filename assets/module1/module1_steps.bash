#!/usr/bin/env bash
## Prevent this script from being sourced
#shellcheck disable=SC2317
return 0  2>/dev/null || :

source "../common/common_bash_libs"

# Check that basic module 1 bootstrap has been done
check_module1_bootstrap() {
  info "Checking that module 1 has been bootstrapped..."
  [[ -f "$HOME/.config/cnd/.module1_bootstrap.done" ]] || { error "Module 1 has not been bootstrapped"; return 1; }
  info "Module 1 has been bootstrapped, continuing..."
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
}

main() {
  check_module1_bootstrap
  #set_myfirstapp_structure
  set_python_environment
  #wrap_up
}

main "$@"