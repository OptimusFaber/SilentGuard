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
        /** Core / profile fault (not named ERROR — Windows headers define ERROR) */
        CORE_ERROR,
    };

    QPixmap GetTrayIcon(TrayIconStatus status);
} // namespace Icon
