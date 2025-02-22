{ lib, pkgs, ... } @ input: let
	inherit (import ./readDir.nix input) readDir;
	inherit (import ./safeFuncs.nix input) safeCall;

	inherit (builtins) map filter;
	inherit (lib.trivial) flip pipe;
	fpipe = flip pipe;

	flattenPaths = let
		flattenPathsImpl = path: obj:
			if builtins.isAttrs obj then
				pipe obj [
					builtins.attrNames
					(map (key: flattenPathsImpl (path ++ [key]) obj.${key}))
					builtins.concatLists
				]
			else if builtins.isList obj then
				map (v: path ++ [ v ]) obj
			else
				[ (path ++ [ toString obj ]) ];
	in flattenPathsImpl [];

	getFileName = builtins.baseNameOf;
	getFileParts = file: let
			parts = pipe file [
				getFileName
				(lib.strings.splitString ".")
			];
			name = pipe parts [ lib.lists.init (lib.strings.concatStringsSep ".") ];
			extension = lib.lists.last parts;
		in {
			inherit name extension;
		};

	commentStr = {
		sh = "#";
		py = "#";
	};
	descriptionFlag = "??";

	descriptionPrefix = ext: (commentStr.${ext}) + descriptionFlag;
	isDescriptionLine = ext: lib.strings.hasPrefix (descriptionPrefix ext);

	isDescEndMark = ext: lib.strings.hasPrefix ((descriptionPrefix ext) + "END");
	cutAtDescriptionEndMark = ext: lines:
		lib.lists.take
			((lib.lists.findFirstIndex (isDescEndMark ext)) (builtins.length lines) lines)
			lines
	;

	stripDescriptionFlag = ext: lib.strings.removePrefix (descriptionPrefix ext);

	readScript =
		file: let
			fileParts = getFileParts file;
			ext = fileParts.extension;
			text = builtins.readFile file;
		in pipe text [
			(lib.strings.splitString "\n")
			# Prevent processing every file line (faster on larger files)
			(cutAtDescriptionEndMark ext)
			(filter (isDescriptionLine ext))
			(map (stripDescriptionFlag ext))
			(lib.strings.concatStringsSep "\n")
			builtins.fromTOML
			(desc: {
				inherit (fileParts) name extension;
				inherit desc text;
			})
		];

	buildRuntimeInputs = dep_repos: fpipe [
		(desc: desc.runtimeInputs or {})
		flattenPaths
		(map (flip lib.getAttrFromPath dep_repos))
		(runtimeInputs: { inherit runtimeInputs; })
	];

	processDescription = dep_repos: fpipe
		(map (f: spec: spec // (f dep_repos spec.desc)) [
			buildRuntimeInputs
		]);

	handlers = {
		# TODO: writeShellApplication uses bash internally. Swap it with dash for faster startups
		# TODO: while rewriting in dash remember to avoid wrapping if it is useless
		sh = safeCall pkgs.writeShellApplication;
		py = (spec: let
			package = (
				pkgs.writers.writePython3Bin spec.name
					# TODO: add support for python libs
					{ libraries = []; doCheck = false; }
					spec.text
			);
			in handlers.sh (spec // {
				text = "${lib.getExe package}";
			})
		);
	};

	makeScript = dep_repos: fpipe [
		readScript
		(processDescription dep_repos)
		(spec: handlers.${spec.extension} spec)
	];
	scriptDir = dep_repos: fpipe [
		readDir
		(map (makeScript dep_repos))
	];
in {
	inherit scriptDir makeScript;
}
