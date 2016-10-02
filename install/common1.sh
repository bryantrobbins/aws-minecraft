# Fetches latest msm.conf, cron job, and init script
function download_latest_files() {
    if [ ! -d "$dl_dir" ]; then
        install_error "Temporary download directory was not created properly"
    fi

    install_log "Downloading latest MSM configuration file"
    wget ${UPDATE_URL}/msm.conf \
        -O "$dl_dir/msm.conf.orig" || install_error "Couldn't download configuration file"

    install_log "Downloading latest MSM cron file"
    wget ${UPDATE_URL}/cron/msm \
        -O "$dl_dir/msm.cron.orig" || install_error "Couldn't download cron file"

    install_log "Downloading latest MSM version"
    wget ${UPDATE_URL}/init/msm \
        -O "$dl_dir/msm.init.orig" || install_error "Couldn't download init file"
}

# Patches msm.conf and cron job to use specified username and directory
function patch_latest_files() {
    # patch config file
    install_log "Patching MSM configuration file"
    sed 's#USERNAME="minecraft"#USERNAME="'$msm_user'"#g' "$dl_dir/msm.conf.orig" | \
        sed "s#/opt/msm#$msm_dir#g" | \
        sed "s#UPDATE_URL=.*\$#UPDATE_URL=\"$UPDATE_URL\"#" >"$dl_dir/msm.conf"

    # patch cron file
    install_log "Patching MSM cron file"
    awk '{ if ($0 !~ /^#/) sub(/minecraft/, "'$msm_user'"); print }' \
        "$dl_dir/msm.cron.orig" >"$dl_dir/msm.cron"

    # patch init file
    install_log "Patching MSM init file"
    cp "$dl_dir/msm.init.orig" "$dl_dir/msm.init"
}

# Installs msm.conf into /etc
function install_config() {
    install_log "Installing MSM configuration file"
    install -b -m0644 "$dl_dir/msm.conf" /etc/msm.conf
    if [ ! -e /etc/msm.conf ]; then
        install_error "Couldn't install configuration file"
    fi
}

# Installs msm.cron into /etc/cron.d
function install_cron() {
    install_log "Installing MSM cron file"
    install -m0644 "$dl_dir/msm.cron" /etc/cron.d/msm || install_error "Couldn't install cron file"
    /etc/init.d/cron reload
}
