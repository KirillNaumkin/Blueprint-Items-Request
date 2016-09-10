require "util"

local debug_mode = false

--===================================================================--
--########################## EVENT HANDLERS #########################--
--===================================================================--

script.on_event(defines.events.on_player_cursor_stack_changed, function(event) 
  if event.player_index then
    local player = game.players[event.player_index]
    if PlayerOk(player) then
      if IsHolding({name = "blueprint"}, player) and player.cursor_stack.is_blueprint_setup() then
        dbg("Holds blueprint or book")
        ShowGUI(player)
      elseif IsHolding({name = "blueprint-book"}, player) then
        local active_blueprints = player.cursor_stack.get_inventory(defines.inventory.item_active)
        if active_blueprints and active_blueprints[1] and active_blueprints[1].valid_for_read and active_blueprints[1].is_blueprint_setup() then
          dbg("Holds blueprint or book")
          ShowGUI(player)
        else
          HideGUI(player)
        end
      else
        HideGUI(player)
      end
    end
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  if event.element and event.element.name == "blueprint_items_request_textfield_value" then
    event.element.text = RemoveNonDigitalSymbols(event.element.text)
  end
end)

script.on_event(defines.events.on_gui_click, function(event) 
  if event.player_index and event.element then
    local player = game.players[event.player_index]
    local element = event.element
    if string.find(element.name, "blueprint_items_request_button") then
      local multiplier = GetCustomMuliplier(player)
      local active_blueprint
      if IsHolding({name = "blueprint"}, player) then
        active_blueprint = player.cursor_stack
      elseif IsHolding({name = "blueprint-book"}, player) then
        active_blueprint = player.cursor_stack.get_inventory(defines.inventory.item_active)[1]
      end
      if element.name == "blueprint_items_request_button_custom_mult" and PlayerOk(player) then
        SetRequestedItemsForBlueprint(player, active_blueprint, multiplier)
      elseif element.name == "blueprint_items_request_button_custom_add" and PlayerOk(player) then
        AddRequestedItemsForBlueprint(player, active_blueprint, multiplier)
      end
    end
  end
end)

--===================================================================--
--############################ FUNCTIONS ############################--
--===================================================================--

function PlayerOk(player)
  return (player and player.connected and player.valid)
end

function IsHolding(simple_stack, player) -- thanks to supercheese (Orbital Ion Cannon author)
	local holding = player.cursor_stack
  simple_stack.count = simple_stack.count or 1
	if holding and holding.valid_for_read and (holding.name == simple_stack.name) and (holding.count >= simple_stack.count) then
		return true
	end
	return false
end

function SetRequestedItemsForBlueprint(player, blueprint_setup, multiplier)
  multiplier = multiplier or 1
  local unrequested_items = GetNeededItems(blueprint_setup, multiplier)
  --Check if player has enough slots totally
  local character = player.character
  if character.request_slot_count < #unrequested_items then
    player.print({"message-not-enough-request-slots", #unrequested_items})
    return false
  end
  --Check which items are already requested and increase requested count up to needed
  for slot_index = 1, character.request_slot_count, 1 do
    local requested_item = character.get_request_slot(slot_index)
    if requested_item then
      for i, item_needed in pairs(unrequested_items) do
        if requested_item.name == item_needed.name then
          if requested_item.count < item_needed.count then
            character.set_request_slot({name = item_needed.name, count = item_needed.count}, slot_index)
          end
          table.remove(unrequested_items, i)
        end
      end
    end
  end
  --Now try to request those items which are still not requested
  for slot_index = 1, character.request_slot_count, 1 do
    local requested_item = character.get_request_slot(slot_index)
    if not requested_item then
      for i, item_needed in pairs(unrequested_items) do
        character.set_request_slot({name = item_needed.name, count = item_needed.count}, slot_index)
        table.remove(unrequested_items, i)
        if #unrequested_items > 0 then
          break
        else
          return true
        end
      end
    end
  end
end

function AddRequestedItemsForBlueprint(player, blueprint_setup, multiplier)
  multiplier = multiplier or 1
  local unrequested_items = GetNeededItems(blueprint_setup, multiplier)
  --Check if player has enough slots totally
  local character = player.character
  if character.request_slot_count < #unrequested_items then
    player.print({"message-not-enough-request-slots", #unrequested_items})
    return false
  end
  --Check which items are already requested and add needed count
  for slot_index = 1, character.request_slot_count, 1 do
    local requested_item = character.get_request_slot(slot_index)
    if requested_item then
      for i, item_needed in pairs(unrequested_items) do
        if requested_item.name == item_needed.name then
          character.set_request_slot({name = item_needed.name, count = requested_item.count + item_needed.count}, slot_index)
          table.remove(unrequested_items, i)
        end
      end
    end
  end
  --Now try to request those items which are still not requested
  for slot_index = 1, character.request_slot_count, 1 do
    local requested_item = character.get_request_slot(slot_index)
    if not requested_item then
      for i, item_needed in pairs(unrequested_items) do
        character.set_request_slot({name = item_needed.name, count = item_needed.count}, slot_index)
        table.remove(unrequested_items, i)
        if #unrequested_items > 0 then
          break
        else
          return true
        end
      end
    end
  end
end

function GetNeededItems(blueprint_setup, multiplier)
  local copy = {}
  for name, count in pairs(blueprint_setup.cost_to_build) do
    table.insert(copy, {name = name, count = count * multiplier})
  end
  return copy
end

function RemoveNonDigitalSymbols(text)
  local result = 0
  local str_len = string.len(text)
  if str_len == 0 then
    return ""
  end
  for i = 1, str_len, 1 do
    local current_symbol = tonumber(string.sub(text, i, i))
    local current_symbol_as_digit = tonumber(current_symbol)
    if current_symbol_as_digit then
      result = result * 10 + current_symbol_as_digit
    end
  end
  result = math.floor(result)
  if not (result > 0) then
    result = 1
  end
  return result
end

function dbg(msg)
  if debug_mode then
    game.players[1].print(msg)
  end
end

--===================================================================--
--############################### GUI ###############################--
--===================================================================--

--Shows mod's GUI.
function ShowGUI(player)
  if PlayerOk(player) then
    local gui = player.gui.top
    if not gui["blueprint_items_request_main_frame"] then
      local main_frame = gui.add({type="frame", name="blueprint_items_request_main_frame", direction = "horizontal", style = "blueprint_items_request_thin_frame"})
      local button = main_frame.add({type="button", name="blueprint_items_request_header", style = "blueprint_items_request_sprite_button_style"})
      local tab = main_frame.add({type="table", name="blueprint_items_request_controls", colspan = 1})
      tab.style.cell_spacing = 1
      tab.style.horizontal_spacing = 0
      tab.style.vertical_spacing = 4
      local flow = tab.add({type="flow", name="blueprint_items_request_flow", direction = "horizontal", style = "blueprint_items_request_thin_flow"})
      flow.add({type="label", name="blueprint_items_request_label", caption = "×"})
      local textfield = flow.add({type="textfield", name="blueprint_items_request_textfield_value", text = "1", style = "blueprint_items_request_textbox"})
      textfield.tooltip = {"tooltip-multiplier"}
      
      local buttons_tab = tab.add({type="table", name="blueprint_items_request_buttons", colspan = 2})
      buttons_tab.style.cell_spacing = 0
      buttons_tab.style.horizontal_spacing = 2
      buttons_tab.style.vertical_spacing = 0
      button = buttons_tab.add({type="button", name="blueprint_items_request_button_custom_mult", caption = "=", style = "blueprint_items_request_button_style"})
      button.tooltip = {"tooltip-button-set-request-custom"}
      button = buttons_tab.add({type="button", name="blueprint_items_request_button_custom_add", caption = "+", style = "blueprint_items_request_button_style"})
      button.tooltip = {"tooltip-button-add-request-custom"}
    end
  end
end

--Hides mod's GUI.
function HideGUI(player)
  if PlayerOk(player) then
    local gui = player.gui.top
    if gui["blueprint_items_request_main_frame"] then
      gui["blueprint_items_request_main_frame"].destroy()
    end
  end
end

function GetCustomMuliplier(player)
  local textfield = player.gui.top["blueprint_items_request_main_frame"]["blueprint_items_request_controls"]["blueprint_items_request_flow"]["blueprint_items_request_textfield_value"]
  return GetPositiveFlooredIntegerOrOne(textfield)
end

function GetPositiveFlooredIntegerOrOne(textfield)
  local number = tonumber(textfield.text)
  if number and number > 1 then
    return math.floor(number)
  else --number is nil or <1
    textfield.text = "1"
    return 1
  end
end