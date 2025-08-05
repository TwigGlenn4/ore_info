-- Ore Info [ore_info] Luanti mod
-- TwigGlenn4


ore_info = {}
local modname = core.get_current_modname()
ore_info.path = core.get_modpath(modname)
local function runfile(file)
    dofile(ore_info.path .. "/" .. file .. ".lua")
end
ore_info.ores = {}
ore_info.ore_types = {}
ore_info.formspec = {}
ore_info.page_title = "Ore Info"
ore_info.formspec.id = "ore_info:main"


-- Find registered ores from core.registered_ores and add them to ore_info.ores and ore_info.ore_types. Sorts ore_info.ore_types by ore name, which keeps mods together.
function ore_info.find_registered_ores()
  -- Check if ores have already been registered, If they are registered twice, there will be duplicates.
  if type(ore_info.ore_types[1]) == "nil" then
    -- print("ore_info - Collecting registered ores")
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
  if type(ore_def.clust_scarcity) ~= "nil" and type(ore_def.clust_num_ores) ~= "nil" then
    rarity = string.format(": %2.2f%%", (ore_def.clust_num_ores/ore_def.clust_scarcity)*100) -- Relative percentage of ores
  elseif type(ore_def.clust_scarcity) ~= "nil" and type(ore_def.clust_size) ~= "nil" then
    rarity = string.format(": %2.2f%%", (ore_def.clust_size/ore_def.clust_scarcity)*100) -- Relative percentage of other clusters (ex. gravel)
  end
  local label_content = core.formspec_escape(string.format("[%6d, %6d]%-8s (%s)", ore_def.y_min, ore_def.y_max, rarity, ore_def.ore_type))
  -- print(ore_info.printable(ore_def))
  return "label["..X..","..Y..";"..label_content.."]"
end

-- Get the formspec for an ore based on a page number.
function ore_info.formspec.get_formspec(page)
  local x_offset = 6
  -- ore_info.list_ore_properties()

  -- build a textlist for registered ores.
  local textlist_items = ""
  for _,ore in ipairs(ore_info.ore_types) do
    local ore_desc = ore_info.formatted_name(core.registered_nodes[ore].description)
    textlist_items = textlist_items..ore_desc..","
  end
  textlist_items = textlist_items:sub(1, -2)

  local page_info = ""
  if page == 0 then -- main page explains the meaning of the data
    page_info = "style_type[label;font_size=*1.3]label["..x_offset..",0.75;"..core.formspec_escape("How it works").."]"..
        "style_type[label;font=mono]label["..x_offset..",1.25;"..core.formspec_escape("[y_min, y_max]: rarity%  (shape)").."]"..
        "style_type[label;font=normal;font_size=*1]label["..x_offset..",2.0;"..core.formspec_escape("Multiple ore definitions allow for the rarity to vary.").."]"..
        "label["..x_offset..",2.5;"..core.formspec_escape("y_min is the lower bound of the ore defintion.").."]"..
        "label["..x_offset..",3.0;"..core.formspec_escape("y_max is the upper bound of the ore defintion.").."]"..
        "label["..x_offset..",3.5;"..core.formspec_escape("shape is the pattern of ore generation.").."]"..
        "label["..x_offset..",4.0;"..core.formspec_escape("rarity is the chance for each node in the given range.").."]"..
        "style_type[label;font=mono]label["..x_offset..",4.5;"..core.formspec_escape("(clust_num_ores/clust_scarcity)*100%").."]"

  else -- Only show content if ore is selceted

    local ore_name = ore_info.ore_types[page]
    local ore_desc = ore_info.formatted_name(core.registered_nodes[ore_name].description)
    local image = core.registered_nodes[ore_name].tiles[1]

    if type(image) ~= "string" then
      image = core.registered_nodes[ore_name].tiles[1].name

      if type(image) ~= "string" then
        image = "unknown_item.png"
      end
    end

    page_info = "image["..x_offset..",0.5;1,1;"..image.."]"..
        "style_type[label;font_size=*1.3]label["..x_offset+1.25 ..",0.75;"..core.formspec_escape(ore_desc).."]"..
        "style_type[label;font=mono;font_size=*1]label["..x_offset+1.25 ..",1.25;"..core.formspec_escape(ore_name).."]"

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
        if ore_def.y_max == n and ore_def.ore == ore_name then
          ore_defs[i] = ore_def
        end
      end
      -- print(i..", "..n..", "..ore_defs[i].ore) -- Print the index, ore y_max, and ore name
    end

    -- Get a formspec chunk label for each ore def and move it further down the page
    local y=2
    for i,ore_def in pairs(ore_defs) do
      page_info = page_info..ore_info.formspec.get_formspec_ore_chunk(x_offset, y, ore_def)
      y = y + 0.5
    end
  end
  -- Build the formspec
  local formspec = {
    "formspec_version[6]",
    "size[18,9]",
    "real_coordinates[true]",

    "image_button_exit[0.5,0.5;1,1;clear.png;ore_info_exit;]",
    "style_type[button;font_size=*1.3]",
    "button[1.75,0.5;3.75,1;main_page;"..core.formspec_escape(ore_info.page_title).."]",

    "textlist[0.5,1.75;5,6.25;ore_list;"..textlist_items.."]",
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
  core.show_formspec(player, ore_info.formspec.id, ore_info.formspec.get_formspec(page))
end

-- Register a command to show the formspec
core.register_chatcommand("ore_info", {
  func = function(player)

    ore_info.formspec.show_to(player)
  end,
})

-- When a player selects a ore from the list, show the page for that ore.
core.register_on_player_receive_fields(function(player, formname, fields)
  -- Only show if the previous formspec was from this mod.
  if formname ~= ore_info.formspec.id then
    return
  end

  if fields.main_page then
    local pname = player:get_player_name()
    ore_info.formspec.show_to(pname, 0)
  end

  if fields.ore_list then
    ore_info.find_registered_ores()
    local pname = player:get_player_name()
    -- core.chat_send_all(pname .. " selected " .. fields.ore_list)
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

function ore_info.formatted_name(value)
  local pos = string.find(value, "\n")

  if pos then
    value = string.sub(value, 1, pos - 1)
  end

  return value
end



runfile("inventory")
-- print("Ore Info loaded!")
