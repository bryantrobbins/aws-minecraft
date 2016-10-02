# Installs init script into /etc/init.d
function install_init() {
    install_log "Installing MSM init file"
    install -b "$dl_dir/msm.init" /etc/init.d/msm || install_error "Couldn't install init file"

    install_log "Making MSM accessible as the command 'msm'"
    ln -s /etc/init.d/msm /usr/local/bin/msm
}

# Enables init script in default runlevels
function enable_init() {
    # OVERLOAD THIS
    install_error "No function defined for enable_init"
}

# Updates rest of MSM using init script updater
function update_msm() {
    install_log "Asking MSM to update itself"
    /etc/init.d/msm update --noinput
}

# Updates rest of MSM using init script updater
function setup_jargroup() {
    install_log "Setup default jar groups"
    /etc/init.d/msm jargroup create minecraft minecraft
}

function install_complete() {
    install_log "Done. Type 'msm help' to get started. Have fun!"
}

function install_msm() {
    config_installation
    add_minecraft_user
    update_system_packages
    install_dependencies
    create_msm_directories
    download_latest_files
    patch_latest_files
    install_config
    install_cron
    install_init
    enable_init
    update_msm
    setup_jargroup
    install_complete
}
