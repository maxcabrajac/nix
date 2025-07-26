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

	readDir = dir: pipe dir [
		builtins.readDir
		(lib.mapAttrsToList (name: _: lib.path.append dir name))
	];

	readDir' = fpipe [
		readDir
		(map (file: { inherit file; } // (fileParts file)))
	];

	mapDir = f: fpipe [
		readDir'
		(map ({file, name, ...}: { ${name} = f file; }))
		lib.mergeAttrsList
	];

	nonDefaultNix = dir: lib.lists.remove (dir + "/default.nix") (readDir dir);
}
