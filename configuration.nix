{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    # This machine had a pre-existing Homebrew at /opt/homebrew. Without this,
    # activation aborts with "An existing ... Homebrew is in the way". Migration
    # replaces the Homebrew repository but keeps installed packages.
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    # Declared so cleanup = "zap" does not try to untap them.
    taps = [
      "anthropics/tap"
      "xcodesorg/made"
    ];
    # Preserved from this machine's pre-existing Homebrew state, plus the
    # repo's own "herdr". cleanup = "zap" removes anything not listed here,
    # so every installed formula is declared explicitly.
    brews = [
      "ada-url"
      "aria2"
      "at-spi2-core"
      "awscli"
      "brotli"
      "c-ares"
      "ca-certificates"
      "cairo"
      "certifi"
      "cloudflared"
      "cmake"
      "cocoapods"
      "code-server"
      "curl"
      "dbus"
      "docker"
      "docker-completion"
      "dwarfutils"
      "fastfetch"
      "ffmpeg"
      "fmt"
      "fnm"
      "fontconfig"
      "freetype"
      "fribidi"
      "gcc"
      "gdbm"
      "gdk-pixbuf"
      "gettext"
      "gh"
      "giflib"
      "git"
      "git-filter-repo"
      "git-lfs"
      "gitleaks"
      "glib"
      "gmp"
      "gnupg"
      "gnutls"
      "go"
      "gpgme"
      "gpgmepp"
      "graphite2"
      "graphviz"
      "gsettings-desktop-schemas"
      "gtk+3"
      "harfbuzz"
      "hdrhistogram_c"
      "helm"
      "herdr"
      "hicolor-icon-theme"
      "icu4c@77"
      "icu4c@78"
      "ideviceinstaller"
      "ios-deploy"
      "isl"
      "jpeg-turbo"
      "kind"
      "krb5"
      "kubernetes-cli"
      "leptonica"
      "libarchive"
      "libassuan"
      "libb2"
      "libepoxy"
      "libev"
      "libevent"
      "libgcrypt"
      "libgpg-error"
      "libidn2"
      "libimobiledevice"
      "libimobiledevice-glue"
      "libksba"
      "libmpc"
      "libnghttp2"
      "libnghttp3"
      "libngtcp2"
      "libomp"
      "libplist"
      "libpng"
      "libssh2"
      "libtasn1"
      "libtatsu"
      "libtiff"
      "libunistring"
      "libusb"
      "libusbmuxd"
      "libuv"
      "libx11"
      "libxau"
      "libxcb"
      "libxdmcp"
      "libxext"
      "libxfixes"
      "libxi"
      "libxrender"
      "libxtst"
      "libyaml"
      "libzip"
      "little-cms2"
      "llama.cpp"
      "llhttp"
      "llvm"
      "lz4"
      "lzo"
      "make"
      "minikube"
      "mpdecimal"
      "mpfr"
      "nettle"
      "node"
      "node@22"
      "npth"
      "nspr"
      "nss"
      "openjdk"
      "openjdk@17"
      "openjpeg"
      "openssl@3"
      "p11-kit"
      "pandoc"
      "pango"
      "pcre"
      "pcre2"
      "pinentry"
      "pixman"
      "plantuml"
      "poppler"
      "portaudio"
      "postgresql@14"
      "putty"
      "python@3.10"
      "python@3.11"
      "python@3.13"
      "readline"
      "redis"
      "rtmpdump"
      "ruby"
      "semgrep"
      "simdjson"
      "simdutf"
      "sqlite"
      "tectonic"
      "tesseract"
      "tree-sitter"
      "unbound"
      "uv"
      "uvwasi"
      "webp"
      "wget"
      "whisper.cpp"
      "xcodes"
      "xorgproto"
      "xz"
      "yyjson"
      "z3"
      "zstd"
    ];
    casks = [
      "android-platform-tools"
      "ant"
      "claude-code@latest"
      "copilot-cli"
      "flutter"
      "font-meslo-lg-nerd-font"
      "gcloud-cli"
      "ghostty"
      "ngrok"
      "wezterm"
    ];
  };
}
