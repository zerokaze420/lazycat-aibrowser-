{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  coreutils,
  unzip,
  zstd,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libxkbcommon,
  nspr,
  nss,
  pango,
  qt5,
  qt6,
  systemd,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lzc-ai-browser";
  version = "2025-12-09";

  src = fetchurl {
    url = "https://dl.lazycat.cloud/aibrowser/lzc-ai-browser-linux-x86_64.tar.zst";
    hash = "sha256-m00nE4oe5fSbdG63B3HRrtKSxPENsX7MWhvT3h2ICII=";
  };

  aiExtensionVersion = "0.9.77";
  aiExtension = fetchurl {
    url = "https://dl.lazycat.cloud/aibrowser/extension/lzc-ai-extension-${finalAttrs.aiExtensionVersion}-chrome.zip";
    hash = "sha256-Wst9j3VKi4HuuupjC9MhZAXD5pV/NwavePU7+04HLVE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
    zstd
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libGL
    libxkbcommon
    nspr
    nss
    pango
    systemd
    libx11
    libxscrnsaver
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];

  runtimeDependencies = [
    qt5.qtbase.out
    qt5.qtwayland.out
    qt6.qtbase.out
    qt6.qtwayland.out
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    zstd -cd "$src" | tar xf -
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/share/lzc-ai-browser" "$out/bin" "$out/share/applications"
    cp -R . "$out/share/lzc-ai-browser"

    substituteInPlace "$out/share/lzc-ai-browser/lzc-ai-browser.desktop" \
      --replace-fail "HOMEDIR/.local/bin/lzc-ai-browser" "$out/bin/lzc-ai-browser" \
      --replace-fail "Icon=lzc-ai-browser" "Icon=$out/share/lzc-ai-browser/product_logo_256.png"
    cp "$out/share/lzc-ai-browser/lzc-ai-browser.desktop" "$out/share/applications/lzc-ai-browser.desktop"

    for size in 16 24 32 48 64 128 256; do
      install -Dm644 "$out/share/lzc-ai-browser/product_logo_$size.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/lzc-ai-browser.png"
    done

    install -d "$out/share/lzc-ai-browser/extensions/cloud.lazycat.app.ai"
    unzip -q "$aiExtension" -d "$out/share/lzc-ai-browser/extensions/cloud.lazycat.app.ai"

    substituteInPlace "$out/share/lzc-ai-browser/extensions/cloud.lazycat.aibrowser.extension.json" \
      --replace-fail "EXECUTABLE_PATH" "$out/bin/lzc-ai-browser-extension"

    export shell="${stdenv.shell}"
    export coreutils="${coreutils}"
    export extensionHash="${finalAttrs.aiExtensionVersion}:sha256-Wst9j3VKi4HuuupjC9MhZAXD5pV/NwavePU7+04HLVE="
    export qtPluginPath="${qt5.qtbase.bin}/${qt5.qtbase.qtPluginPrefix}:${qt5.qtwayland.bin}/${qt5.qtbase.qtPluginPrefix}:${qt6.qtbase.out}/${qt6.qtbase.qtPluginPrefix}:${qt6.qtwayland.out}/${qt6.qtbase.qtPluginPrefix}"
    substituteAll "${./scripts/lzc-ai-browser.in}" "$out/bin/lzc-ai-browser"
    substituteAll "${./scripts/lzc-ai-browser-extension.in}" "$out/bin/lzc-ai-browser-extension"
    chmod +x "$out/bin/lzc-ai-browser" "$out/bin/lzc-ai-browser-extension"

    patchelf --set-rpath "${qt5.qtbase.out}/lib:${stdenv.cc.cc.lib}/lib" \
      "$out/share/lzc-ai-browser/chrome-linux/libqt5_shim.so"
    patchelf --set-rpath "${qt6.qtbase.out}/lib:${stdenv.cc.cc.lib}/lib" \
      "$out/share/lzc-ai-browser/chrome-linux/libqt6_shim.so"

    runHook postInstall
  '';

  meta = {
    description = "LCMD AI Browser binary package";
    homepage = "https://dl.lazycat.cloud/aibrowser/";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "lzc-ai-browser";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
