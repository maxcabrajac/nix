{
	programs.niri.settings = {
		input.keyboard.xkb = {
			layout = "us,us";
			variant = "colemak,";
		};

		binds = let
			KC_LANG1 = "Hangul";
		in {
			${KC_LANG1}.action.switch-layout = "next";
		};
	};
}
