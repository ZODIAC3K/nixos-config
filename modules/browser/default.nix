{
  # ===========================================================
  # 🌐 Browser preferences
  # ===========================================================
  programs.firefox.enable = false;  # disable default Firefox, we use Dev Edition
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox-devedition.desktop";
    "x-scheme-handler/http" = "firefox-devedition.desktop";
    "x-scheme-handler/https" = "firefox-devedition.desktop";
    "x-scheme-handler/ftp" = "firefox-devedition.desktop";
    "x-scheme-handler/chrome" = "firefox-devedition.desktop";
  };
}

