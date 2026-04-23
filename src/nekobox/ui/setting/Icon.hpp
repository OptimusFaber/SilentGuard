#ifdef _WIN32
#include <winsock2.h>
#include <windows.h>
#endif

#pragma once

#include <QPixmap>

namespace Icon {

    enum TrayIconStatus {
        NONE,
        RUNNING,
        SYSTEM_PROXY,
        VPN,
        DNS,
        SYSTEM_PROXY_DNS,
        /** Core / profile fault while user expects an active session */
        ERROR,
    };

    QPixmap GetTrayIcon(TrayIconStatus status);
} // namespace Icon
