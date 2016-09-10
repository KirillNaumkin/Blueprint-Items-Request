MOD_NAME = "__Blueprint Items Request__"

data.raw["gui-style"].default["blueprint_items_request_thin_frame"] = {
  type = "frame_style",
  parent="frame_style",
  top_padding  = 0,
  bottom_padding = 0,
  left_padding = 0,
  right_padding = 0,
}
data.raw["gui-style"].default["blueprint_items_request_thin_flow"] = {
  type = "flow_style",
  parent="flow_style",
  top_padding  = 0,
  bottom_padding = 0,
  left_padding = 0,
  right_padding = 0,
}
data.raw["gui-style"].default["blueprint_items_request_thin_label"] = {
  type = "label_style",
  --parent="flow_style",
  top_padding  = 0,
  bottom_padding = 0,
  left_padding = 0,
  right_padding = 0,
}
data.raw["gui-style"].default["blueprint_items_request_button_style"] = {
  type = "button_style",
  parent = "button_style",
  font = "bir_big_font",
  width = 32,
  height = 32,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  left_click_sound =
  {
    {
      filename = "__core__/sound/gui-click.ogg",
      volume = 1
    }
  }
}
data.raw["gui-style"].default["blueprint_items_request_textbox"] = {
  type = "textfield_style",
  parent = "textfield_style",
  minimal_width = 44,
  maximal_width = 44,
  font = "bir_big_font",
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
}

local bgs = 
{
  type = "monolith",
  monolith_image =
  {
    filename = MOD_NAME .. "/graphics/character-logistic-slots.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    x = 0,
    y = 0,
  }
}

data.raw["gui-style"].default["blueprint_items_request_sprite_button_style"] = {
  type = "button_style",
  parent = "button_style",
  width = 64,
  height = 64,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  font = "default-button",
  default_graphical_set = bgs,
  hovered_graphical_set = bgs,
  clicked_graphical_set = bgs
}

data:extend({
  {
    type = "font",
    name = "bir_small_font",
    from = "default",
    size = 14
  },
  {
    type = "font",
    name = "bir_big_font",
    from = "default",
    size = 18
  },
})