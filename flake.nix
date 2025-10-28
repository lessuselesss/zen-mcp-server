{
  description = "Zen MCP Server - AI-powered MCP server with multiple model providers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Use uv to run zen-mcp-server from the current directory
        # This leverages uv's dependency management instead of Nix's
        zen-mcp-server-script = pkgs.writeShellScriptBin "zen-mcp-server" ''
          exec ${pkgs.uv}/bin/uvx --from ${self} zen-mcp-server "$@"
        '';

      in
      {
        packages = {
          default = zen-mcp-server-script;
          zen-mcp-server = zen-mcp-server-script;
        };

        apps = {
          default = {
            type = "app";
            program = "${zen-mcp-server-script}/bin/zen-mcp-server";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python311
            uv
          ];

          shellHook = ''
            echo "Zen MCP Server development environment"
            echo "Run: uv sync to install dependencies"
            echo "Run: uv run zen-mcp-server to start the server"
          '';
        };
      }
    );
}
