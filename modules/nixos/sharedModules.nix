{ util, ... }: {
	imports = util.allNixFiles ../shared
		|> map (m: import m "os")
	;
}
