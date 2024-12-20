let
  #builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICllOC9xAgR6ROJSFotRNrfErKGayL+lVd0fjC3g3VtG builder@localhost";
  mbpMe = import ../modules/ssh-key;
  me =
    [
      # This is the mini key, disabling for now because I need to rotate it out
      #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAB/hlAvEO3FKG2I4aCmV/3v0Ebenh5Ye3QTo9LXzA4O sebas@mini"
      #builder
    ]
    ++ mbpMe;
in
{
  "me".publicKeys = me;
}
