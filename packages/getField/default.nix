{...}: {
	packages = {pkgs, ...}: { inherit (pkgs.makeScript { inherit pkgs; } ./scripts/getField.bash) getField;};
}
