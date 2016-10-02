UPDATE_URL="https://raw.githubusercontent.com/msmhq/msm/master"
source /root/install/common0.sh
source /root/install/common1.sh
source /root/install/common2.sh

function update_system_packages() {
    install_log "Updating sources"
    yum update --skip-broken -y || install_error "Couldn't update packages"
}

function install_dependencies() {
    install_log "Installing required packages"
    yum install -y screen rsync zip java || install_error "Couldn't install dependencies"
}

function enable_init() {
    install_log "Enabling automatic startup and shutdown"
    chkconfig --add msm
}

install_msm
