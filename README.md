# LCMD AI Browser Flake

Nix flake package for the LCMD AI Browser binary release.

Repository: <https://github.com/zerokaze420/lazycat-aibrowser->

## Usage

Run directly:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:zerokaze420/lazycat-aibrowser-
```

Install through an overlay:

```nix
{
  inputs.lzc-ai-browser.url = "github:zerokaze420/lazycat-aibrowser-";

  nixpkgs.overlays = [
    inputs.lzc-ai-browser.overlays.default
  ];

  environment.systemPackages = [
    pkgs.lzc-ai-browser
  ];
}
```

Use the Home Manager module:

```nix
{
  inputs.lzc-ai-browser.url = "github:zerokaze420/lazycat-aibrowser-";

  imports = [
    inputs.lzc-ai-browser.homeManagerModules.default
  ];

  programs.lzc-ai-browser = {
    enable = true;
    defaultBrowser = false;
  };
}
```

## What This Packages

- The upstream Linux x86_64 browser tarball from
  `https://dl.lazycat.cloud/aibrowser/lzc-ai-browser-linux-x86_64.tar.zst`
- The pinned AI extension zip from
  `https://dl.lazycat.cloud/aibrowser/extension/`
- Desktop entry and hicolor icons
- Native messaging host manifest
- Runtime wrapper for the upstream `$HOME/.local/share/lzc-ai-browser` layout

The wrapper initializes the browser profile under
`$XDG_CONFIG_HOME/lzc-ai-browser` or `$HOME/.config/lzc-ai-browser` on first
run. It installs the bundled auto-login extension, the pinned AI extension, and
the native messaging host manifest expected by upstream.

Because the upstream browser is distributed as a proprietary binary, Nix users
must allow unfree packages with `NIXPKGS_ALLOW_UNFREE=1 --impure` or a Nixpkgs
configuration such as `nixpkgs.config.allowUnfree = true`.

## Local Checks

```sh
NIXPKGS_ALLOW_UNFREE=1 nix flake check --no-build --impure
NIXPKGS_ALLOW_UNFREE=1 nix build .#default --impure
```

For an isolated smoke test:

```sh
env HOME=/tmp/lzc-ai-browser-test \
  XDG_CONFIG_HOME=/tmp/lzc-ai-browser-test/config \
  timeout 8s result/bin/lzc-ai-browser \
  --no-first-run --disable-extensions --disable-gpu --disable-dev-shm-usage about:blank
```

Exit code `124` from `timeout` means the browser stayed running until the test
ended.

## Updating

1. Check the latest upstream installer:

   ```sh
   curl -fsSL https://dl.lazycatmicroserver.com/aibrowser/install.sh
   ```

2. Update the browser tarball hash:

   ```sh
   nix-prefetch-url https://dl.lazycat.cloud/aibrowser/lzc-ai-browser-linux-x86_64.tar.zst
   ```

3. Check the latest extension update XML, then update `aiExtensionVersion` and
   its hash in `default.nix`:

   ```sh
   curl -fsSL https://dl.lazycat.cloud/aibrowser/extension/lzc-ai-extension-updates.xml
   nix-prefetch-url https://dl.lazycat.cloud/aibrowser/extension/lzc-ai-extension-<version>-chrome.zip
   ```

4. Convert legacy base32 hashes to SRI if needed:

   ```sh
   nix hash convert --hash-algo sha256 --to sri <base32-hash>
   ```
