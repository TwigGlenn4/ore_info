ore_info = {}
local modname = minetest.get_current_modname()
ore_info.path = minetest.get_modpath(modname)
local function runfile(file)
    dofile(ore_info.path .. "/" .. file .. ".lua")
end
ore_info.ores = {}
ore_info.ore_types = {}
ore_info.formspec = {}


-- Find registered ores from core.registered_ores and add them to ore_info.ores and ore_info.ore_types. Sorts ore_info.ore_types by ore name, which keeps mods together.
function ore_info.find_registered_ores()
  -- Check if ores have already been registered, If they are registered twice, there will be duplicates.
  if type(ore_info.ore_types[1]) == "nil" then
    print("ore_info - Collecting registered ores")
    -- find all registered ores
    for _,ore_def in pairs(core.registered_ores) do
      table.insert(ore_info.ores, ore_def)   -- Add ore_def to ore_info.ores
      ore_info.ore_types[ore_def.ore] = true -- Add ore name to ore_info.ore_types
    end
    -- ore_info.list_ore_properties()

    -- sort ore_info.ore_types
    local a = {}
    for n in pairs(ore_info.ore_types) do table.insert(a, n) end
    table.sort(a)
    for i,n in ipairs(a) do
      -- print(i..", "..n) -- Uncomment to list registered ores
      ore_info.ore_types[i] = n
    end
  end
end

-- Get a formspec label for an ore definition
function ore_info.formspec.get_formspec_ore_chunk(X, Y, ore_def)
  local rarity = ""
  -- Make sure the math can be done. Dirt lacks some keys and would cause errors if this math was performed
  if type(ore_def.clust_scarcity) ~= "nil" and type(ore_def.clust_size) ~= "nil" then
    rarity = ",  at a rarity of  "..math.floor((ore_def.clust_size/ore_def.clust_scarcity)*10000+0.5)/100 .."%." -- Relative percentage
  else
    rarity = "."
  end
  return "label["..X..","..Y..";"..minetest.formspec_escape("Generates between y values of "..ore_def.y_max.." and "..ore_def.y_min..rarity).."]"
end

-- Get the formspec for an ore based on a page number.
function ore_info.formspec.get_formspec(page)
  -- ore_info.list_ore_properties()

  -- build a textlist for registered ores.
  local textlist_items = ""
  for _,ore in ipairs(ore_info.ore_types) do
    local ore_desc = minetest.registered_nodes[ore].description
    textlist_items = textlist_items..ore_desc..","
  end
  textlist_items = textlist_items:sub(1, -2)

  local page_info = ""
  if page == 0 then -- Show a generic page

    local text1 = "Ore Information"
    page_info = "label[4,0.75;"..minetest.formspec_escape(text1).."]"

  else -- Show a page with ore information
    local ore_name = ore_info.ore_types[page]
    local ore_desc = minetest.registered_nodes[ore_name].description
    page_info = "label[4,0.75;"..minetest.formspec_escape("Ore: "..ore_desc).."]label[4,1.05;"..minetest.formspec_escape("Node: "..ore_name).."]"

    -- Create a list of ore definitions for the selected ore
    local ore_defs = {}
    for _,ore_def in pairs(ore_info.ores) do
      if ore_def.ore == ore_name then
        -- print(ore_def.ore)
        ore_defs[ore_def.y_max] = ore_def
      end
    end

    -- Sort the short ore definition list by y_max from highest to lowest
    local tbl = {}
    for _,n in pairs(ore_defs) do table.insert(tbl, n.y_max) end
    table.sort(tbl, function(a, b) return a > b end)
    ore_defs = {}
    for i,n in ipairs(tbl) do
      for _,ore_def in pairs(ore_info.ores) do
        if ore_def.y_max == n and ore_name then
          ore_defs[i] = ore_def
        end
      end
      -- print(i..", "..n..", "..ore_defs[i].ore) -- Print the index, ore y_max, and ore name
    end

    -- Get a formspec chunk label for each ore def and move it further down the page
    local y=1.5
    for i,ore_def in pairs(ore_defs) do
      page_info = page_info..ore_info.formspec.get_formspec_ore_chunk(4.25, y, ore_def)
      y = y + 0.5
    end
  end
  -- Build the formspec
  local formspec = {
      "size[15,8]",
      "real_coordinates[true]",
      "textlist[0.5,0.5;3,7;ore_list;"..textlist_items.."]",
      page_info
    }
  -- combine the table into a single string.
  return table.concat(formspec, "")
end

-- Show a formspec page to a player. page nil or a formspec textlist field.
function ore_info.formspec.show_to(player, page)
  if type(page) == "nil" then
    page = 0
  else
    page = string.match(page, ":(.*)")
    if type(page) == "nil" or page == "" then
      page = 0
    else
      page = tonumber(page)
    end
  end
  -- print("page# = "..page)
  minetest.show_formspec(player, "ore_info:main", ore_info.formspec.get_formspec(page))
end

-- Register a command to show the formspec
minetest.register_chatcommand("ore_info", {
  func = function(player)

    ore_info.formspec.show_to(player)
  end,
})

-- When a player selects a ore from the list, show the page for that ore.
minetest.register_on_player_receive_fields(function(player, formname, fields)
  -- Only show if the previous formspec was from this mod.
  if formname ~= "ore_info:main" then
    return
  end

  if fields.ore_list then
    ore_info.find_registered_ores()
    local pname = player:get_player_name()
    -- minetest.chat_send_all(pname .. " selected " .. fields.ore_list)
    ore_info.formspec.show_to(pname, fields.ore_list)
  end
end)








-- make a table printable
function ore_info.printable(value)
  local output = ""
  if type(value) == "nil" then
    return ""
  elseif type(value) == "table" then
    for k,v in pairs(value) do
      output = output.."key:"..ore_info.printable(k).."     value: "..ore_info.printable(v).."\n"
    end
  else
    return value
  end
  return output
end
-- List each ore definition as a indented tree of keys and values.
function ore_info.list_ore_properties()
  print("Listing ore properties")
  for _,ore_def in pairs(ore_info.ores) do
    local ore_name = ore_def.ore
    print(ore_name)
    for k,v in pairs(ore_def) do
      print("  "..k)
      print("    "..ore_info.printable(v))
    end
  end
end

-- Add a button to unified_inventory to open the menu
if minetest.get_modpath("unified_inventory") then
  unified_inventory.register_page("ore_info:main", {
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
  unified_inventory.register_button("ore_info:main", {
		type = "image",
		image = "ore_info_button.png",
		tooltip = "Ore Info",
		hide_lite = true
		-- ^ Button is hidden when following two conditions are met:
		--   Configuration line `unified_inventory_lite = true`
		--   Player does not have the privilege `ui_full`
	})
end

print("Ore Info loaded!")
