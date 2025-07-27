{ lib, util, ... } @ input: let
	inherit (util) deepMerge readDir' fileParts mapDir;
	inherit (builtins) map filter;
	inherit (lib.trivial) flip;

	flattenPaths = let
		flattenPathsImpl = path: obj:
			if builtins.isAttrs obj then
				obj
				|> builtins.attrNames
				|> map (key: flattenPathsImpl (path ++ [key]) obj.${key})
				|> builtins.concatLists
			else if builtins.isList obj then
				map (v: path ++ [ v ]) obj
			else
				[ (path ++ [ toString obj ]) ];
	in flattenPathsImpl [];

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
			fParts = fileParts file;
			ext = fParts.extension;
			text = builtins.readFile file;
		in text
		|> lib.strings.splitString "\n"
		# Prevent processing every file line (faster on larger files)
		|> cutAtDescriptionEndMark ext
		|> filter (isDescriptionLine ext)
		|> map (stripDescriptionFlag ext)
		|> lib.strings.concatStringsSep "\n"
		|> builtins.fromTOML
		|> (desc: {
			inherit (fParts) name extension;
			inherit desc text;
		})
	;

	buildRuntimeInputs = dep_repos: spec:
		spec.runtimeInputs or {}
		|> flattenPaths
		|> map (flip lib.getAttrFromPath dep_repos)
		|> (runtimeInputs: { inherit runtimeInputs; })
	;

	# TODO: improve this
	inheritDescription = attr: _: lib.attrsets.filterAttrs (name: _: name == attr);

	processDescription = dep_repos: desc:
		desc
		|> map (f: spec: spec // (f dep_repos spec.desc)) [
			buildRuntimeInputs
			(inheritDescription "inheritPath")
		];
in {
	packages = { pkgs }: let
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
					inheritPath = false;
					env = {};
				};
				spec = deepMerge [defaultSpec wrapRequiredSpec receivedSpec];
				wrapIsRequired = (builtins.intersectAttrs wrapRequiredSpec spec) != wrapRequiredSpec;
				wrapper = if spec.useBash then writeBashBin else writeDashBin;
			in
				if wrapIsRequired || spec.package == null then
					let
						parts = [
							(optionalString (spec.runtimeInputs != [] || spec.inheritPath != true)
								"export PATH=${makeBinPath spec.runtimeInputs}${optionalString spec.inheritPath ":$PATH"}"
							)
							(lib.mapAttrsToList (name: val: "export ${name}=${lib.escapeShellArg val}") spec.env)
							spec.text
						];
					in
					parts
					|> lib.flatten
					|> filter (line: line != "")
					|> concatStringsSep "\n"
					|> wrapper spec.name
				else
					spec.package;
			bash = spec: handlers.sh (spec // { useBash = true; });
			py = spec: handlers.from_package spec (
				writePython3Bin
					spec.name
					# TODO: add support for python libs
					{ libraries = []; doCheck = false; }
					spec.text
			);
			from_package = spec: package:
				handlers.sh (spec // { inherit package; text = ''exec ${lib.getExe package} "$@"''; });
		};
	in rec {
		makeScriptInject = default_spec: dep_repos: file_path:
			file_path
			|> readScript
			|> processDescription dep_repos
			|> (spec: handlers.${spec.extension} (deepMerge [default_spec spec]))
		;

		scriptDirInject = default_spec: dep_repos: dir:
			lib.fixedPoints.fix (self: mapDir
				(makeScriptInject default_spec (dep_repos // { inherit self; }))
				dir
			);

		makeScript = makeScriptInject {};
		scriptDir = scriptDirInject {};
	};
}

