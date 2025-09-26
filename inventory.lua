-- Ore Info [ore_info] Luanti mod
-- TwigGlenn4


-----------------------
-- unified_inventory --
-----------------------

if core.global_exists("unified_inventory") then
  -- print("[ore_info]: Enabling support for unified_inventory...")
  unified_inventory.register_page(ore_info.formspec.id, {
		get_formspec = function(player)
			-- ^ `player` is an `ObjectRef`
			-- Compute the formspec string here
      ore_info.find_registered_ores()
      ore_info.formspec.show_to(player:get_player_name())
			return {
				formspec = "",
				-- ^ Final form of the formspec to display
				draw_inventory = false,   -- default `true`
				-- ^ Optional. Hides the player's `main` inventory list
				draw_item_list = false,   -- default `true`
				-- ^ Optional. Hides the item list on the right side
				formspec_prepend = false, -- default `false`
				-- ^ Optional. When `false`: Disables the formspec prepend
			}
		end
	})
  unified_inventory.register_button(ore_info.formspec.id, {
		type = "image",
		image = "ore_info_button.png",
		tooltip = "Ore Info",
		hide_lite = true
		-- ^ Button is hidden when following two conditions are met:
		--   Configuration line `unified_inventory_lite = true`
		--   Player does not have the privilege `ui_full`
	})
  core.register_on_player_receive_fields(function(player, formname, fields)
		if fields.ore_info_exit then --return to unified_inventory page
			unified_inventory.set_inventory_formspec(player, "craft")
			return true
		end
		return false
	end)
end


-----------
-- sfinv --
-----------

if core.global_exists("sfinv") and sfinv.enabled then
	if core.global_exists("sfinv_buttons") then
		local button_action = function(player)
			ore_info.find_registered_ores()
			ore_info.formspec.show_to(player:get_player_name())
		end

		sfinv_buttons.register_button("ore_info", {
			image = "ore_info_button.png",
			tooltip = "Show ore depth and rarity",
			title = "Ore Info",
			action = button_action,
		})
	else
	-- print("[ore_info]: Enabling support for sfinv...")
		local orig_get = sfinv.pages["sfinv:crafting"].get
		sfinv.override_page("sfinv:crafting", {
			get = function(self, player, context)
				local fs = orig_get(self, player, context)
				return fs .. "image_button[0,1;1,1;ore_info_button.png;ore_info_gui;]" ..
					"tooltip[ore_info;Ore Info]"
			end
		})
	--show the form when the button is pressed and hide it when done
		core.register_on_player_receive_fields(function(player, formname, fields)
			if fields.ore_info_gui then --main page
				ore_info.find_registered_ores()
				ore_info.formspec.show_to(player:get_player_name())
				return true
			elseif fields.ore_info_exit then --return to sfinv page
				sfinv.set_page(player, "sfinv:crafting")
				return true
			end
			return false
		end)
	end
end


--------------------
-- inventory_plus --
--------------------

if core.global_exists("inventory_plus") then
  -- print("[ore_info]: Enabling support for inventory_plus...")
  core.register_on_joinplayer(function(player)
		inventory_plus.register_button(player, "ore_info_gui", "Ore Info")
	end)

  --show the form when the button is pressed and hide it when done
  local gui_player_formspecs = {}
  core.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if fields.ore_info_gui then --main page
      gui_player_formspecs[name] = player:get_inventory_formspec()
      ore_info.find_registered_ores()
			ore_info.formspec.show_to(player:get_player_name())
      return true
    elseif fields.ore_info_exit then --return to inventory_plus page
      if gui_player_formspecs[name] then
        inventory_plus.set_inventory_formspec(player, inventory_plus.get_formspec(player, "main"))
      end
      return true
    end
    return false
  end)
end
