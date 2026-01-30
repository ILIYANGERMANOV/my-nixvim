{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nixvim, ... }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = eachSystem (pkgs:
        let
          ideModule = import ./nix/ide.nix;

          nvimPkg = nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
            inherit pkgs;
            module = ideModule;
          };

          basePackages = [
            pkgs.docker-client
            pkgs.git
            pkgs.git-lfs
            pkgs.nodejs_24
            pkgs.corepack
            pkgs.nodePackages.typescript
            pkgs.nodePackages.typescript-language-server
          ];
          commonEnv = {
            OTEL_SERVICE_NAME = "frontline-web-localhost";
            OTEL_EXPORTER_OTLP_ENDPOINT = "http://localhost:4318";
            OTEL_EXPORTER_OTLP_PROTOCOL = "http/protobuf";
          };
        in
        {
          default = pkgs.mkShell {
            env = commonEnv;
            packages = basePackages;
          };

          ide = pkgs.mkShell {
            env = commonEnv;
            packages = basePackages ++ [ nvimPkg ];

            shellHook = ''
              echo "Web IDE Environment Loaded. Run 'nvim' to start."
            '';
          };
        });
    };
}
