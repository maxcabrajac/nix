{lib, pkgs, config, maxLib, ...}: with lib; let
	fpipe = flip pipe;
	inherit (maxLib) checkCollisions;
in {
	options.global.impure_repos = let
		repo = types.submodule {
			options = {
				path = mkOption {
					type = types.path;
				};
				url = let
					regex = "(github|gitlab):(.*)";
					matching_group_names = [ "handle" "repo" ];
				in
					mkOption {
						type = types.strMatching regex;
						apply = fpipe [
							(match regex)
							(zipListsWith lib.nameValuePair matching_group_names)
							listToAttrs
							({ handle, ... } @ input: input // { domain = "${handle}.com"; })
						];
					};
			};
		};
	in
		mkOption {
			type = types.listOf repo;
			default = [];
			apply = checkCollisions "global.impure_repos" ({path, ...}: path);
		};

	config = {
		home.activation.impureRepos = let
			packages = with pkgs; [
				git
				openssh
				coreutils
			];

			add_to_path = pipe packages [
				(map (p: "${p}/bin"))
				(concatStringsSep ":")
			];

			activationPre = /*bash*/''
				export USESSHGIT=$(${pkgs.coreutils}/bin/ls ${config.home.homeDirectory}/.ssh/id_* > /dev/null && echo "true" || echo "false")
				if [ $USESSHGIT = "false" ]; then
					echo "SSH disabled, you might be unable to push"
				fi

				manageRepo() {(
					# Arguments
					REPO_DIR="$1"
					DOMAIN="$2"
					REPO_NAME="$3"
					TAG="$4"

					export PATH=${add_to_path}:$PATH

					REPO_SSH="git@$DOMAIN:$REPO_NAME.git"
					REPO_HTTP="https://$DOMAIN/$REPO_NAME.git"
					PUSH_REPO=$([ $USESSHGIT = "true" ] && echo $REPO_SSH || echo $REPO_HTTP)
					PUSH_REPO_WRONG=$([ $USESSHGIT = "false" ] && echo $REPO_SSH || echo $REPO_HTTP)

					if [ -e $REPO_DIR/.git ]; then
						cd $REPO_DIR
						PULL_ORIGIN=$(git remote get-url origin --no-push)
						if [ "$PULL_ORIGIN" = "$REPO_SSH" ]; then
							echo "Changing pull origin for $TAG from $PULL_ORIGIN to $REPO_HTTP"
							run --silence git remote set-url origin "$REPO_HTTP"
							PULL_ORIGIN="$REPO_HTTP"
						fi

						PUSH_ORIGIN=$(git remote get-url origin --push)
						if [ "$PUSH_ORIGIN" = "$PUSH_REPO_WRONG" ]; then
							echo "Changing push origin for $TAG from $PUSH_ORIGIN to $PUSH_REPO"
							run --silence git remote set-url origin --push "$PUSH_REPO"
							PUSH_ORIGIN="$PUSH_REPO"
						fi

						if [ "$PULL_ORIGIN" != "$REPO_HTTP" ] || [ "$PUSH_ORIGIN" != "$PUSH_REPO" ]; then
							echo "Repo on $REPO_DIR is not compatible with $TAG"
							echo "Current origin: $PULL_ORIGIN (pull), $PUSH_ORIGIN (push)"
							echo "Expected origin: $REPO_HTTP (pull), $PUSH_REPO (push)"
							exit 1
						fi

						if [ "$(git status --porcelain | wc -l)" != "0" ]; then
							echo "$TAG on $REPO_DIR is dirty, skipping"
							exit 0
						fi

						echo "Syncing $TAG on $REPO_DIR"

						run --silence git pull
					else
						echo "Cloning $TAG into $REPO_DIR"
						mkdir -p $REPO_DIR
						run --silence git clone $REPO_HTTP $REPO_DIR
						cd $REPO_DIR
						run --silence git remote set-url origin --push $PUSH_REPO
					fi
				)}

				MANAGER_PIDS=""
			'';
			# TODO: Create a bash function on activationPre so outputScript size is smaller
			activateRepo = { path, url }: let
				inherit (url) domain repo handle;
				tag = "${handle}:${repo}";
			in
				/*bash*/''
					manageRepo '${path}' '${domain}' '${repo}' '${tag}' &
					MANAGER_PIDS+=" $!"
				'';

				activationPost = /*bash*/''
				for pid in $MANAGER_PIDS; do
					wait $pid
				done
				'';

			parts = [
				activationPre
				(map activateRepo config.global.impure_repos)
				activationPost
			];
			activate = pipe parts [
				flatten
				concatLines
			];
		in
			hm.dag.entryAfter
				[ "linkGeneration" "installPackages" ]
				activate;
	};
}
