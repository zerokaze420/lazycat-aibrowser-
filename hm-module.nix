{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.lzc-ai-browser;
in
{
  options.programs.lzc-ai-browser = {
    enable = lib.mkEnableOption "LCMD AI Browser";

    package = lib.mkPackageOption pkgs "lzc-ai-browser" { };

    defaultBrowser = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to register LCMD AI Browser as the default browser for common web MIME types.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.mimeApps = lib.mkIf cfg.defaultBrowser {
      enable = true;
      defaultApplications = {
        "text/html" = [ "lzc-ai-browser.desktop" ];
        "x-scheme-handler/http" = [ "lzc-ai-browser.desktop" ];
        "x-scheme-handler/https" = [ "lzc-ai-browser.desktop" ];
        "application/xhtml+xml" = [ "lzc-ai-browser.desktop" ];
        "application/xml" = [ "lzc-ai-browser.desktop" ];
        "application/pdf" = [ "lzc-ai-browser.desktop" ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ];
}
