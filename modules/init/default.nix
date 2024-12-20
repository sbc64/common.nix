{
  ...
}: {
  environment = {
    etc."ssh/ssh_host_ed25519_key".text = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACBTtwgmjSouG/MAMCC4yvysZs0aL2pLJk1yxrdee5C3kAAAAJhZ4U5iWeFO
      YgAAAAtzc2gtZWQyNTUxOQAAACBTtwgmjSouG/MAMCC4yvysZs0aL2pLJk1yxrdee5C3kA
      AAAEAFCBVH4auEDJTae/YwnI6m+wP7iunFUjfPgxrELOOwS1O3CCaNKi4b8wAwILjK/Kxm
      zRovaksmTXLGt157kLeQAAAAFHNlYmFzQFNlYmFzdGlhbnMtTUJQAQ==
      -----END OPENSSH PRIVATE KEY-----
    '';
    etc."ssh/ssh_host_ed25519_key.pub".text = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFO3CCaNKi4b8wAwILjK/KxmzRovaksmTXLGt157kLeQ default@host'';
  };
}
