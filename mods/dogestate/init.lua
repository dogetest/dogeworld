--dogestate protection mod
local FEE = 1
if minetest.setting_get('dogestate.fee') then
  FEE = tonumber(minetest.setting_get('dogestate.fee'))
end

minetest.register_privilege("freedman", {
	description = "Wont pay interaction fee.",
  give_to_singleplayer= false
})

local fee=function(nick)
  if minetest.check_player_privs(nick, "freedman") then
    return true
  else
    if economy.withdraw(nick, FEE, "Interaction fee") then
      dogecoin.transfer(nick, SOURCE_DOGEACC, FEE, "Interaction fee")
      return true
    else
      return false
    end
  end
end

--State wraps node's on_place and on_dig
local wrap_on_place=function(on_place)
  return function(itemstack, placer, pointed_thing)
    local fee_then_place=function(itemstack, placer, pointed_thing)
      local pname=economy.pname(placer)
      if fee(pname) then
        return on_place(itemstack, placer, pointed_thing)
      else
        return itemstack
      end
    end
    if (minetest.registered_nodes[minetest.get_node(pointed_thing.under).name] or {}).on_rightclick then
      if placer:get_player_control()['sneak'] then
        return fee_then_place(itemstack, placer, pointed_thing)
      else
        return on_place(itemstack, placer, pointed_thing)
      end
    else
      return fee_then_place(itemstack, placer, pointed_thing)
    end
    return itemstack
  end
end

local wrap_on_dig=function(on_dig)
  return function(pos, oldnode, digger)
    local pname=economy.pname(digger)
    if fee(pname) then
      return on_dig(pos, oldnode, digger)
    else
      return true
    end
  end
end

--Wrap registered nodes definitions
local wrap_place_definition=function(name)
  local old_def = minetest.registered_nodes[name]
  local old_on_place = old_def.on_place or minetest.item_place
  minetest.override_item(name, { on_place = wrap_on_place(old_on_place) })
end

local wrap_dig_definition=function(name)
  local old_def = minetest.registered_nodes[name]
  local old_on_dig = old_def.on_dig or minetest.node_dig
  minetest.override_item(name, { on_dig = wrap_on_dig(old_on_dig) })
end

for name, definition in pairs(minetest.registered_nodes) do
  wrap_place_definition(name)
  wrap_dig_definition(name)
end

--Wrap minetest.register_node
local wrap_register_node=function(register_node)
  return function(name, definition)
    local old_on_place=definition.on_place or minetest.item_place
    local old_on_dig=definition.on_dig or minetest.node_dig
    definition.on_place=wrap_on_place(old_on_place)
    definition.on_dig=wrap_on_dig(old_on_dig)
    return register_node(name, definition)  
  end
end

old_register_node=minetest.register_node
minetest.register_node=wrap_register_node(old_register_node)
