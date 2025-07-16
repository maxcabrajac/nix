{ lib, ... }: let
	inherit (lib) flip pipe;
	fpipe = flip pipe;
in rec {
	fileName = builtins.baseNameOf;
	fileParts = file: let
			parts = pipe file [
				fileName
				(lib.strings.splitString ".")
			];
			name = pipe parts [ lib.lists.init (lib.strings.concatStringsSep ".") ];
			extension = lib.lists.last parts;
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
