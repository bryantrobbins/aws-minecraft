msm_dir="/opt/msm"
msm_user="minecraft"
msm_user_system=false
dl_dir="$(mktemp -d -t msm-XXX)"

# Outputs an MSM INSTALL log line
function install_log() {
    echo -e "\n\033[1;32mMSM INSTALL: $*\033[m"
}

# Outputs an MSM INSTALL ERROR log line and exits with status code 1
function install_error() {
    echo -e "\n\033[1;37;41mMSM INSTALL ERROR: $*\033[m"
    exit 1
}

### NOTE: all the below functions are overloadable for system-specific installs
### NOTE: some of the below functions MUST be overloaded due to system-specific installs

function config_installation() {
    install_log "Configure installation"
    echo -n "Install directory [${msm_dir}]: "
    echo -n "New server user to be created [${msm_user}]: "
    echo -n "Add new user as system account? [${msm_user_system}]: "
}

# Runs a system software update to make sure we're using all fresh packages
function update_system_packages() {
    # OVERLOAD THIS
    install_error "No function definition for update_system_packages"
}

# Installs additional dependencies (screen, rsync, zip, wget) using system package manager
function install_dependencies() {
    # OVERLOAD THIS
    install_error "No function definition for install_dependencies"
}

# Verifies existence of or adds user for Minecraft server (default "minecraft")
function add_minecraft_user() {
    install_log "Creating default user '${msm_user}'"
    if $msm_user_system; then
        useradd ${msm_user} --home "$msm_dir"
    else
        useradd ${msm_user} --system --home "$msm_dir"
    fi
}

# Verifies existence and permissions of msm server directory (default /opt/msm)
function create_msm_directories() {
    install_log "Creating MSM directories"
    if [ ! -d "$msm_dir" ]; then
        mkdir -p "$msm_dir" || install_error "Couldn't create directory '$msm_dir'"
    fi
    chown -R $msm_user:$msm_user "$msm_dir" || install_error "Couldn't change file ownership for '$msm_dir'"
}
