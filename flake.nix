{
	description = "Kreyren's CAD of Drill Alignment Tool";

	inputs = {
		# Release inputs
		nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-23.05";
		nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
		nixpkgs-master.url = "github:nixos/nixpkgs/master";
		nixpkgs-staging.url = "github:nixos/nixpkgs/staging";
		nixpkgs-staging-next.url = "github:nixos/nixpkgs/staging-next";

		# Principle inputs
		nixos-flake.url = "github:srid/nixos-flake";
		# nur.url = "github:nix-community/NUR/master";
		flake-parts.url = "github:hercules-ci/flake-parts";
		mission-control.url = "github:Platonic-Systems/mission-control";
		flake-root.url = "github:srid/flake-root";
	};

	outputs = inputs @ { self, ... }:
		inputs.flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
        # ./path # To import from paths

				inputs.flake-root.flakeModule
				inputs.mission-control.flakeModule
			];

			systems = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];

			perSystem = { system, config, ... }: {
				mission-control.scripts = {
					# Editors
					freecad = {
						description = "FreeCad (Fully Integrated)";
						category = "Integrated Editors";
						exec = "${inputs.nixpkgs.legacyPackages.${system}.freecad}/bin/freecad ./drill-alignment-tool.FCStd";
					};
				};
				devShells.default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
					name = "DAT-devshell";
					nativeBuildInputs = [
						inputs.nixpkgs.legacyPackages.${system}.bashInteractive # For terminal
						inputs.nixpkgs.legacyPackages.${system}.nil # Needed for linting
            inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt # Nixpkgs formatter
						inputs.nixpkgs.legacyPackages.${system}.git # Working with the codebase
						inputs.nixpkgs.legacyPackages.${system}.freecad # Core 
					];
					inputsFrom = [ config.mission-control.devShell ];
          # Environmental Variables
          LC_ALL = "C"; # To disable weeb-mode, bcs that's kinda too much rn
				};

				formatter = inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
			};
		};
}
