export def nsw [] {
  sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw
}

export def nboot [] {
  sudo nixos-rebuild boot --flake ~/nixos-config#nixos-btw
}

export def ntest [] {
  sudo nixos-rebuild test --flake ~/nixos-config#nixos-btw
}

export def nupdate [] {
  cd ~/nixos-config
  nix flake update
  sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw
}

export def nclean [] {
  sudo nix-collect-garbage -d
}
