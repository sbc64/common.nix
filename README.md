# common.nix

This repository is a small library of `nixos` modules I made for myself and helper functions in [`./lib/default.nix`](./lib/default.nix). I was having multiple pieces of the same code in separate repositories and machines. We all know what happens when you have the same code functionality in multiple places... it gets messy.


GitHub is mirror, the repository is located at [sr.ht](https://git.sr.ht/~sebohe/common.nix).

## TODO

- [ ] Create a wrapped nvim based on this: https://github.com/pete3n/nixvim-flake/blob/main/flake.nix#L46
- [ ] Create a tui-dev module that is different to the tui you would use on working servers.
- [ ] Add [tailscale](https://registry.terraform.io/providers/tailscale/tailscale/0.16.1) terraform server provisioning to spin up servers more easily
- [ ] Add terranix
