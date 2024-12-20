let
  builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICllOC9xAgR6ROJSFotRNrfErKGayL+lVd0fjC3g3VtG builder@localhost";
  mbpMe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUAbxX6TG1lsVbPPG4qk5GTFP2H7rDjRpGkFWqXKB2I sbc64@pm.me";
  me = [
    mbpMe
    # This is the mini key, disabling for now because I need to rotate it outa2
    #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAB/hlAvEO3FKG2I4aCmV/3v0Ebenh5Ye3QTo9LXzA4O sebas@mini"
    builder
  ];
in {
  "me".publicKeys = me;
}
