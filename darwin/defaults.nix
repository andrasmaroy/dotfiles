{ ... }:
{
  # macOS defaults, ported from roles/macos. Typed system.defaults options are
  # used for the stable, well-known keys; CustomUserPreferences carries the
  # rest (arbitrary domain/key/value, exactly like osx_defaults). Per-ByHost
  # keys (host: currentHost) and the imperative bits (firewall, caps-lock) live
  # in darwin/activation.nix. The killall/activateSettings handlers are run by
  # nix-darwin's own defaults activation, so they are not ported.
  system.defaults = {
    # roles/macos/tasks/dock.yml
    dock = {
      autohide = true;
      tilesize = 28;
      show-recents = false;
      orientation = "left";
      mru-spaces = false;
      wvous-tl-corner = 5; # start screensaver in the top-left hot corner
    };

    # roles/macos/tasks/finder.yml
    finder = {
      FXPreferredViewStyle = "clmv";
      FXDefaultSearchScope = "SCcf";
      ShowPathbar = true;
      _FXSortFoldersFirst = true;
    };

    # roles/macos/tasks/misc.yml
    screencapture.disable-shadow = true;
    LaunchServices.LSQuarantine = false;

    # NSGlobalDomain keys from finder.yml, trackpad.yml, keyboard.yml.
    NSGlobalDomain = {
      # finder.yml
      NSNavPanelExpandedStateForSaveMode = true;
      PMPrintingExpandedStateForPrint = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      AppleShowAllExtensions = false;
      AppleShowScrollBars = "Always";
      AppleScrollerPagingBehavior = true;
      # trackpad.yml
      "com.apple.trackpad.scaling" = 0.6875;
      "com.apple.swipescrolldirection" = true;
      # keyboard.yml
      ApplePressAndHoldEnabled = true;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      AppleKeyboardUIMode = 3;
    };

    CustomUserPreferences = {
      # dock.yml + trackpad.yml (dock-domain gesture toggles) without a typed
      # option. spans-displays is written to com.apple.dock to match Ansible.
      "com.apple.dock" = {
        expose-group-apps = false;
        spans-displays = true;
        AppleSpacesSwitchOnActivate = true;
        showAppExposeGestureEnabled = true;
        showLaunchpadGestureEnabled = false;
        showMissionControlGestureEnabled = true;
        showDesktopGestureEnabled = true;
      };

      # finder.yml keys without a typed option.
      "com.apple.finder" = {
        NewWindowTarget = "PfHm";
        FXRemoveOldTrashItems = true;
        ShowSidebar = true;
        FinderSpawnTab = false;
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      # controlcentre.yml clock (com.apple.menuextra.clock).
      "com.apple.menuextra.clock" = {
        ShowDayOfWeek = true;
        ShowDate = 2;
      };

      # controlcentre.yml menu-bar item visibility (standard domain).
      "com.apple.controlcenter" = {
        "NSStatusItem Visible Battery" = true;
        "NSStatusItem Visible BentoBox" = true;
        "NSStatusItem Visible Bluetooth" = false;
        "NSStatusItem Visible Clock" = true;
        "NSStatusItem Visible FocusModes" = true;
        "NSStatusItem Visible Item-0" = false;
        "NSStatusItem Visible Item-1" = false;
        "NSStatusItem Visible Item-2" = false;
        "NSStatusItem Visible Item-3" = false;
        "NSStatusItem Visible Item-4" = false;
        "NSStatusItem Visible Item-5" = false;
        "NSStatusItem Visible Item-6" = false;
        "NSStatusItem Visible Sound" = true;
        "NSStatusItem Visible WiFi" = false;
      };

      # trackpad.yml device settings (both the internal and Bluetooth trackpad
      # domains; not currentHost). Values match the Ansible types verbatim.
      "com.apple.AppleMultitouchTrackpad" = {
        FirstClickThreshold = 1;
        SecondClickThreshold = 1;
        ForceSuppressed = false;
        ActuateDetents = 1;
        TrackpadRightClick = true;
        Clicking = 1;
        TrackpadPinch = 1;
        TrackpadTwoFingerDoubleTapGesture = 1;
        TrackpadRotate = 1;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadFiveFingerPinchGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadThreeFingerDrag = true;
      };
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        TrackpadRightClick = true;
        Clicking = 1;
        TrackpadPinch = 1;
        TrackpadTwoFingerDoubleTapGesture = 1;
        TrackpadRotate = 1;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadFiveFingerPinchGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadThreeFingerDrag = true;
      };

      # misc.yml domains without a typed option.
      "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
      "com.apple.ncprefs".content_visibility = 2;

      # keyboard.yml FN key emoji picker.
      "com.apple.HIToolbox".AppleFnUsageType = 2;

      # terminal.yml. NOTE: Terminal.app's real domain is com.apple.Terminal
      # (capital T); the Ansible role used lowercase, replicated 1:1 here.
      "com.apple.terminal" = {
        AppleShowScrollBars = "WhenScrolling";
        ApplePressAndHoldEnabled = false;
      };

      # NSGlobalDomain keys without a typed option (not currentHost).
      NSGlobalDomain = {
        "com.apple.trackpad.forceClick" = true;
        ContextMenuGesture = 1;
        AppleEnableSwipeNavigateWithScrolls = true;
        "com.apple.sound.beep.feedback" = 1;
      };
    };
  };
}
