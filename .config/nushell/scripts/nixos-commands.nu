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
  do --capture-errors { sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5 }
  do --capture-errors { sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot }
  do --capture-errors { sudo nix-store --gc }
}
