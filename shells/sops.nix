{ pkgs, inputs, self }:
let
  system = pkgs.stdenv.hostPlatform.system;
  nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    inherit pkgs;
    module = import "${self}/programs/nvim/ide.nix";
    extraSpecialArgs = { profile = "sops"; };
  };
in pkgs.mkShell {
  packages = with pkgs; [
    nvim
    age
    sops
    ssh-to-age
    whois # provides mkpasswd
  ];
  shellHook = ''
    echo "SOPS shell loaded — 'age-keygen', 'sops', 'ssh-to-age' and 'mkpasswd' are available."
    echo "See docs/SOPS.md for the full workflow."
  '';
}
