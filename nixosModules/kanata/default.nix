{ config
, lib
, ...
}:
let
  cfg = config.kanata;
  inherit (lib) mkIf types mkOption;
in
{
  options.kanata = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    devices = mkOption {
      type = with types; listOf str;
      default = [
        "/dev/input/by-id/usb-Cherry_GmbH_CHERRY_Wired_Keyboard-event-kbd"
        "/dev/input/by-id/usb-413c_Dell_KB216_Wired_Keyboard-event-kbd"
        "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
      ];
    };
  };
  config = mkIf cfg.enable {
    hardware.uinput.enable = true; # Why is this needed???
    services.kanata = {
      enable = true;
      keyboards = {
        internalKeyboard = {
          devices = cfg.devices;
          extraDefCfg = "process-unmapped-keys yes";
          config = /** lisp **/ ''
            (deflayermap (custom-map-example)
              caps esc
              esc  caps

              ;; You can use _ , __ or ___ instead of specifying a key name to map all
              ;; keys that are not explicitly mapped in the layer.
              ;; E.g. esc and caps above will not be overwritten.
              ;;
              ;; _    maps only keys that are in defsrc.
              ;; __   excludes mapping keys that are in defsrc.
              ;; ___  maps both, keys that are in `defsrc`, and keys that are not.
              ;;
              ;; The two- and three-underscore variants require
              ;; "process-unmapped-keys yes" in defcfg to work.

              ;; ___ XX ;; maps all keys that are not mapped explicitly in the layer
              ;;          ;; (i.e. esc and caps above) to "no-op" to disable the key.
              _ XX   ;; maps all keys that are in defsrc and are not mapped in the layer
              __ XX  ;; maps all keys that are NOT in defsrc and are not mapped in the layer
            )
            #|
            (defsrc
             ;;caps
             a s d f j k l ;
            )
            (defvar
             tap-time 75
             hold-time 200
            )
            (defalias
             ;;caps (tap-hold 100 100 esc lctl)
             a (tap-hold $tap-time $hold-time a lmet)
             s (tap-hold $tap-time $hold-time s lalt)
             d (tap-hold $tap-time $hold-time d lsft)
             f (tap-hold $tap-time $hold-time f lctl)
             j (tap-hold $tap-time $hold-time j rctl)
             k (tap-hold $tap-time $hold-time k rsft)
             l (tap-hold $tap-time $hold-time l ralt)
             ; (tap-hold $tap-time $hold-time ; rmet)
            )

            (deflayer base
             @caps @a  @s  @d  @f  @j  @k  @l  @;
            )
            |#
          '';
        };
      };
    };
  };
}
