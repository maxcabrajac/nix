{ lib, ... }: let
	inherit (lib)
		concatStringsSep
		drop
		flip
		pipe
		take
	;
	fpipe = flip pipe;
in rec {
	fileName = builtins.baseNameOf;
	fileParts = file: let
			parts = pipe file [
				fileName
				(lib.strings.splitString ".")
			];
			name = parts |> take 1 |> concatStringsSep ".";
			extension = parts |> drop 1 |> concatStringsSep ".";
		in {
			inherit name extension;
		};

	readDirOpt = { recursive? false } @ opt: originalDir: let
		a = 1;
		readDirImpl = self: dir:
			dir
			|> builtins.readDir
			|> lib.mapAttrsToList (name: type: {
				inherit type name;
				path = lib.path.append dir name;
				parts = fileParts name;
			})
			|> map ({ type, path, ... } @ file:
				if recursive && type == "directory" then
					self path
				else
					file
			)
			|> lib.flatten
		;
	in
		lib.fix (readDirImpl) originalDir
	;

	readDir = readDirOpt {};

	nonDefaultNix = dir:
		dir
		|> readDirOpt { recursive = false; }
		|> map (f: f.path)
		|> lib.lists.remove (dir + "/default.nix");


	allNixFiles = dir:
		dir
		|> readDirOpt { recursive = true; }
		|> lib.filter (f: f.parts.extension == "nix")
		|> map (f: f.path)
	;
}
