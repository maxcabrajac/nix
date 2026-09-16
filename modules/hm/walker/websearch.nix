{ lib, ... }: {
	hm.base = { config, pkgs, ... }: {
		programs.walker.config.providers.default = [ "menus:websearch" ];
		programs.elephant.menus.websearch = {
			Icon = "edit-find";
			Action = "${pkgs.xdg-utils}/bin/xdg-open %VALUE%";
			SearchPriority = [ "keywords" ];
			engines = let
				baseEngines = config.web.sites
					|> map ({ name, alias, bookmark, search_engine }: {
						inherit alias name;
						url = "https://${bookmark}";
						default = false;
					} // (lib.optionalAttrs (!isNull search_engine) {
						search_url = "https://${search_engine}";
					}));
				defaultEngine = {
					name = "the Internet";
					alias = "search";
					search_url = "https://${config.web.default_search_engine}";
					default = true;
				};
			in
				baseEngines ++ [defaultEngine]
			;

			urlEncode = lib.mkLuaInline /* lua */ ''
				function(str)
					function encodeChar(c)
						return string.format("%%%02X", c:byte())
					end
					return str:gsub(".", encodeChar)
				end
			'';

			searchUrl = lib.mkLuaInline /* lua */ ''
				function(engine, term)
					return engine.search_url:gsub("%%%%", urlEncode(term):gsub("%%", "%%%%"))
				end
			'';

			asLowScore = lib.mkLuaInline /* lua */ ''
				function(input)
					function impl(s)
						if s:len() == 0 then
							return s
						end
						return s:sub(1, 1) .. "." .. impl(s:sub(2))
					end
					return "....." .. impl(input)
				end
			'';

			searchEntry = lib.mkLuaInline /* lua */ ''
				function(engine, term, query, lowScore)
					if lowScore then
						query = asLowScore(query)
					end
					return {
						Text = "Search \"" .. term .. "\" on " .. engine.name,
						Value = searchUrl(engine, term),
						Keywords = { query },
					}
				end
			'';

			GetEntries = lib.mkLuaInline /* lua */ ''
				function(query)
					local entries = {}
					function entries:add(v)
						table.insert(self, v)
					end

					tag_end = (query:find(" ") or query:len() + 1) - 1
					tag = query:sub(1, tag_end)
					term = query:sub(tag_end + 2)

					for i, engine in ipairs(engines) do
						if engine.url then
							entries:add({
								Text = engine.name,
								-- Extra space so this gets used when term is empty
								Keywords = { engine.alias .. " " },
								Value = engine.url,
							})
						end

						if engine.search_url then
							if tag == engine.alias and term:len() ~= 0 then
								entries:add(searchEntry(engine, term, query))
							end

							if engine.default then
								entries:add(searchEntry(engine, query, query, true))
							end
						end
					end

					return entries
				end
			'';
		};
	};
}
