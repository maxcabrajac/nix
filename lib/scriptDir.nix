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
		bash = "#";
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

	# TODO: improve this
	inheritDescription = attr: _: lib.attrsets.filterAttrs (name: _: name == attr);

	processDescription = dep_repos: fpipe
		(map (f: spec: spec // (f dep_repos spec.desc)) [
			buildRuntimeInputs
			(inheritDescription "inheritPath")
		]);

	handlers = with pkgs.writers; {
		sh = receivedSpec: with lib.strings; let
			defaultSpec = {
				name = null;
				text = null;
				package = null;
				useBash = false;
			};
			wrapRequiredSpec = {
				runtimeInputs = [];
				inheritPath = true;
			};
			spec = defaultSpec // wrapRequiredSpec // receivedSpec;
			wrapIsRequired = (builtins.intersectAttrs wrapRequiredSpec spec) != wrapRequiredSpec;
			wrapper = if spec.useBash then writeBashBin else writeDashBin;
		in
			if wrapIsRequired || spec.package == null then
				wrapper spec.name
					(concatStringsSep "\n" [
						(optionalString (spec.runtimeInputs != [] || spec.inheritPath != true)
							''export PATH="${makeBinPath spec.runtimeInputs}${optionalString spec.inheritPath ":$PATH"}"''
						)
						spec.text
					])
			else
				spec.package;
		bash = spec: handlers.sh (spec // { useBash = true; });
		py = spec: handlers.from_package spec
			(writePython3Bin
				spec.name
				# TODO: add support for python libs
				{ libraries = []; doCheck = false; }
				spec.text
		);
		from_package = spec: package:
			handlers.sh (spec // { inherit package; text = ''exec ${lib.getExe package}''; });
	};

	makeScript = dep_repos: fpipe [
		readScript
		(processDescription dep_repos)
		(spec: {
			${spec.name} = handlers.${spec.extension} spec;
		})
	];

	scriptDir = dep_repos: dir: let
		repo = pipe dir [
			readDir
			(map (makeScript dep_repos))
			(lib.lists.foldr (a: b: a // b) {})
		];
	in
		repo // { all = lib.attrsets.attrValues repo; };

in {
	inherit scriptDir makeScript;
}
