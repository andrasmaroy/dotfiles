{ ... }:
{
  # The genuinely imperative parts of roles/macos, as activation scripts:
  #   - firewall (socketfilterfw)              -> root, postActivation
  #   - per-ByHost (currentHost) defaults       -> user, postUserActivation
  #   - caps-lock -> escape per-keyboard remap  -> user, postUserActivation
  # These run only on `darwin-rebuild switch`, never on `build`.

  # roles/macos/tasks/firewall.yml. Runs as root.
  system.activationScripts.postActivation.text = ''
    fw=/usr/libexec/ApplicationFirewall/socketfilterfw

    if ! "$fw" --getglobalstate | /usr/bin/grep -qi "firewall is enabled"; then
      "$fw" --setglobalstate on
    fi
    if "$fw" --getallowsigned | /usr/bin/grep -qE "signed built-in software ENABLED"; then
      "$fw" --setallowsigned off
    fi
    if "$fw" --getallowsigned | /usr/bin/grep -qE "downloaded signed software ENABLED"; then
      "$fw" --setallowsignedapp off
    fi
  '';

  # Per-ByHost defaults (host: currentHost) and the caps-lock remap. Runs as
  # the primary user, so `defaults -currentHost write` targets the right
  # ByHost domain.
  system.activationScripts.postUserActivation.text = ''
    # roles/macos/tasks/screensaver.yml
    /usr/bin/defaults -currentHost write com.apple.screensaver idleTime -int 300
    /usr/bin/defaults -currentHost write com.apple.screensaver showClock -bool true

    # roles/macos/tasks/controlcentre.yml (currentHost integer keys)
    /usr/bin/defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -int 1
    /usr/bin/defaults -currentHost write com.apple.controlcenter Bluetooth -int 8
    /usr/bin/defaults -currentHost write com.apple.controlcenter FocusModes -int 18
    /usr/bin/defaults -currentHost write com.apple.controlcenter Sound -int 18
    /usr/bin/defaults -currentHost write com.apple.controlcenter WiFi -int 8

    # roles/macos/tasks/trackpad.yml (NSGlobalDomain currentHost keys)
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.enableSecondaryClick -bool true
    /usr/bin/defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.pinchGesture -bool true
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.twoFingerDoubleTapGesture -int 1
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.rotateGesture -bool true
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.fourFingerHorizSwipeGesture -int 2
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture -int 3
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.fourFingerVertSwipeGesture -int 2
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.fourFingerPinchSwipeGesture -int 2
    /usr/bin/defaults -currentHost write -g com.apple.trackpad.fiveFingerPinchSwipeGesture -int 2

    # roles/macos/tasks/keyboard.yml: caps-lock -> escape. The mapping is
    # stored per keyboard, so fetch the internal keyboard's product ID (Apple
    # vendor ID is always 1452). Dst 30064771113 = Escape, Src 30064771129 =
    # Caps Lock. Written as an old-style plist so it is stored as a dict, not
    # a string.
    product_id=$(/usr/sbin/ioreg -a -l | /usr/bin/xpath -q -e '(//*[string[text()="Apple Internal Keyboard / Trackpad"]]/key[text() = "ProductID"]/following-sibling::integer[1]/text())[1]' 2>/dev/null || true)
    if [ -n "$product_id" ]; then
      /usr/bin/defaults -currentHost write -g "com.apple.keyboard.modifiermapping.1452-''${product_id}-0" '({HIDKeyboardModifierMappingDst=30064771113;HIDKeyboardModifierMappingSrc=30064771129;})'
    fi

    # Apply the ByHost/keyboard changes without a logout (was the "Activate
    # Settings" handler).
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
