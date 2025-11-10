SUMMARY = "WPA Supplicant WiFi configuration for wlan0"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://wpa_supplicant-wlan0.conf \
    file://wpa_supplicant-wlan0.service \
    file://dhcpcd-wlan0.service \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "wpa_supplicant-wlan0.service dhcpcd-wlan0.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    # Install wpa_supplicant config
    install -d ${D}${sysconfdir}/wpa_supplicant
    install -m 0600 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/

    # Install systemd services
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/wpa_supplicant-wlan0.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/dhcpcd-wlan0.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} = " \
    ${sysconfdir}/wpa_supplicant/wpa_supplicant-wlan0.conf \
    ${systemd_system_unitdir}/wpa_supplicant-wlan0.service \
    ${systemd_system_unitdir}/dhcpcd-wlan0.service \
"

RDEPENDS:${PN} = "wpa-supplicant dhcpcd iproute2"
RRECOMMENDS:${PN} = "kernel-module-brcmfmac kernel-module-brcmutil"