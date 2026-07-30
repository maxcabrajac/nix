{ util, ... }: {
	imports = util.allNixFiles ../shared_system_to_home
		|> map (m: import m "os")
	;
}
