local GLOBAL
local CONFIG
local Inst = require "chores-lib.instance"
local Inspect = require "inspect"
local PrefabLibary = require("chores-lib.prefablibrary")
local modname = KnownModIndex:GetModActualName("To Do Chores [Forked]")

local adultTreeAnims = {
  "idle_tall",
  "sway1_loop_tall",
  "sway2_loop_tall",
}

local adultShrub = {
  "idle_tall",
  "mined_tall",
  "hit_tall",
}

local lumberPickup = {
  log = true,
  twigs = true,
  charcoal = "charcoal",
  pinecone = "pinecone",
  acorn = "pinecone",
  twiggy_nut = "pinecone",
}

local minerPickup = {
  flint = true,
  rocks = true,
  nitre = "nitre",
  goldnugget = "goldnugget",
  ice = "ice",
  moonrocknugget = "moonrocknugget",
  marble = "marble",
  marblebean = "marble",
}

local minerMine = {
  rock1 = "nitre",
  rock_petrified_tree = "nitre",
  rock2 = "goldnugget",
  rock_ice = "ice",
  rock_moon = "moonrocknugget",
  rock_flintless = "rocks",
  marblepillar = "marble",
  marbletree = "marble",
  statueharp = "marble",
  statue_marble = "marble",
  sculpture_rookbody = "marble",
  sculpture_bishopbody = "marble",
  sculpture_knightbody = "marble",
}

local collectorPickup = {
  flint = "flint",
  carrot = "carrot",
  petals = "petals",
  green_cap = "green_cap",
  red_cap = "green_cap",
  blue_cap = "green_cap",
  cutgrass = "cutgrass",
  twigs = "twigs",
  berries = "berries",
  berries_juicy = "berries",
  poop = "guano",
  guano = "guano",
  spoiled_food = "guano",
  rottenegg = "guano",
  fertilizer = "guano",
  glommerfuel = "guano",
}

local collectorPick = {
  carrot_planted = "carrot",
  flower = "petals",
  planted_flower = "petals",
  flower_rose = "petals",
  green_mushroom = "green_cap",
  red_mushroom = "green_cap",
  blue_mushroom = "green_cap",
  grass = "cutgrass",
  sapling = "twigs",
  berrybush = "berries",
  berrybush2 = "berries",
  berrybush_juicy = "berries",
}

local diggerPickup = {
  dug_grass = "dug_grass",
  cutgrass = "dug_grass",
  dug_berrybush = "dug_berrybush",
  dug_berrybush2 = "dug_berrybush",
  dug_berrybush_juicy = "dug_berrybush",
  berries = "dug_berrybush",
  berries_juicy = "dug_berrybush",
  dug_sapling = "dug_sapling",
  twigs = "dug_sapling",
}

local diggerDig = {
  grass = "dug_grass",
  berrybush = "dug_berrybush",
  berrybush2 = "dug_berrybush",
  berrybush_juicy = "dug_berrybush",
  sapling = "dug_sapling",
}

local planterDeploy = {
  dug_grass = "dug_grass",
  dug_berrybush = "dug_berrybush",
  dug_berrybush2 = "dug_berrybush",
  dug_berrybush_juicy = "dug_berrybush",
  dug_sapling = "dug_sapling",
  pinecone = "pinecone",
  acorn = "acorn",
  twiggy_nut = "twiggy_nut",
  marblebean = "marblebean",
}

local fertilizeItem = {
  poop = "poop",
  guano = "poop",
  spoiled_food = "spoiled_food",
  rottenegg = "rottenegg",
  fertilizer = "fertilizer",
  glommerfuel = "glommerfuel",
}

local trapPickup = {
  smallmeat = "smallmeat",
  froglegs = "froglegs",
  silk = "silk",
  spidergland = "spidergland",
  monstermeat = "monstermeat",
  spoiled_food = "spoiled_food",
}

local triggeredTrapAnims = {
  "side",
  "trap_loop",
}

local ChoreLib = PrefabLibary(function (proto)
  local stat = {}
  if proto.components.tool ~= nil then
    stat.tool = {}
    stat.tool.CHOP = proto.components.tool:CanDoAction(ACTIONS.CHOP)
    stat.tool.DIG = proto.components.tool:CanDoAction(ACTIONS.DIG)
    stat.tool.MINE = proto.components.tool:CanDoAction(ACTIONS.MINE)
  end
  return stat
end)

local function _isChopper(item) --check if the object can chop
  if item == nil then return false end
  local stat = ChoreLib:Get(item)
  if stat == nil then return false end
  if stat.tool == nil then return false end
  return stat.tool.CHOP
end

local function _isDigger(item) --check if the object can dig
  if item == nil then return false end
  local stat = ChoreLib:Get(item)
  if stat == nil then return false end
  if stat.tool == nil then return false end
  return stat.tool.DIG
end
local function _isMiner(item) --check if the object can mine
  if item == nil then return false end
  local stat = ChoreLib:Get(item)
  if stat == nil then return false end
  if stat.tool == nil then return false end
  return stat.tool.MINE
end


local AutoChores = Class(function(self, inst)
  self.inst = inst
  self.INST = Inst(inst)
  self.trapOldPos = nil

  print("AutoChores")
  self.inst:ListenForEvent("actionfailed", function(inst) inst.components.auto_chores:StopLoop() end)--when an action has failed stops the loop


  self.ActionButtonDown = true
  self:OverridePC()
  self:OverrideInput()

end,
nil,
{ })
function AutoChores:SetGlobal(global)
  GLOBAL=global
end
function AutoChores:SetConfig(config)
  CONFIG=config
end
function AutoChores:SetTask(task, flag, placer)
  self:ClearPlacer()
  self.task = task
  self.task_flag = flag
  self.task_placer = placer
  --  print("SetTask", task, flag, placer)
end
function AutoChores:ForceStop()
  -- body
  if self.inst.components.locomotor then
    self.inst.components.locomotor:Clear()
  end
  self:StopLoop()
end

function AutoChores:ClearPlacer()

  if self.task_placer == nil then return end
  for k, v in pairs(self.task_placer) do
    v:Remove()
  end
  self.task_placer = nil
end


function AutoChores:StopLoop()
  print("StopLoop")
  if self.task then
    self.task = nil
    self.trapOldPos = nil
    self:ClearPlacer()
  end
end
function AutoChores:GetAction()
  if self.task == "axe" then
    return self:GetLumberJackAction()
  elseif self.task == "pickaxe" then
    return self:GetMinerAction()
  elseif self.task == "backpack" then
    return self:GetCollectorAction()
  elseif self.task == "shovel" then
    return self:GetDiggerAction()
  elseif self.task == "book_gardening" then
    return self:GetPlanterAction()
  elseif self.task == "guano" then
    return self:GetFertilizeAction()
  elseif self.task == "trap" then
    return self:GetTrapAction()
  end
end

function AutoChores:OverrideInput()
  local auto_chores = self
  local _fnOrig = TheInput.IsControlPressed
  local function _fnOver(self, control)
    if auto_chores.task ~= nil then
      if control == CONTROL_ACTION then return auto_chores.ActionButtonDown end
    end
    return _fnOrig(self, control)
  end
  TheInput.IsControlPressed = _fnOver
end

function AutoChores:OverridePC()--player controller
  local auto_chores = self
  local PLAYER = Inst(self.inst)
  local pc = self.inst.components.playercontroller

  local _fnOrig =  pc.GetActionButtonAction
  local function _fnOver(self, force_target)

    if auto_chores.task == nil then return _fnOrig(self, force_target) end

    --Don't want to spam the action button before the server actually starts the buffered action
    --Also check if playercontroller is enabled
    --Also check if force_target is still valid
    if (not self.ismastersim and (self.remote_controls[CONTROL_ACTION] or 0) > 0) or
      not self:IsEnabled() or
      (force_target ~= nil and (not force_target.entity:IsVisible() or force_target:HasTag("INLIMBO") or force_target:HasTag("NOCLICK"))) then
      --"DECOR" should never change, should be safe to skip that check
      return
    end

    if self:IsDoingOrWorking() then return end

    if self.passtime ~= nil and self.passtime > 0 then --delay
      self.passtime = self.passtime - 1
      return
    end

    self.passtime = 10

    local bufaction = auto_chores:GetAction()
    if bufaction == nil then
      auto_chores:StopLoop()
    else
      if bufaction.action == ACTIONS.BUILD  then

        if not PLAYER:builder_IsBusy() then
          PLAYER:builder_MakeRecipeBy(bufaction.recipe)
          self.passtime = 20
        end

      elseif bufaction.action == ACTIONS.EQUIP then

        PLAYER:inventory_UseItemFromInvTile(bufaction.invobject)
        return

      elseif bufaction.action == ACTIONS.DEPLOY then

        local act = bufaction
        local obj = act.invobject

        if( GLOBAL.TheWorld.Map:CanDeployPlantAtPoint(act.pos, obj) ) then
          if self.ismastersim then
            self.inst.components.combat:SetTarget(nil)
          elseif self.locomotor == nil then
            self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
            SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.x, act.pos.z, act.rotation ~= 0 and act.rotation or nil)
          elseif self:CanLocomote() then
            act.preview_cb = function()
              self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
              local isreleased = true
              SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.x, act.pos.z, act.rotation ~= 0 and act.rotation or nil, isreleased)
            end
          end
          self:DoAction(act)
          self.passtime = 0
        end
        return -- DEPLOY Action need RPC instead of return bufaction

      elseif bufaction.action == ACTIONS.FERTILIZE
        or bufaction.action == ACTIONS.CHECKTRAP
        or bufaction.action == ACTIONS.DROP then

        local act = bufaction
        if self.ismastersim then
          self.inst.components.combat:SetTarget(nil)
        else
          local mouseover = act.action ~= ACTIONS.DROP and act.target or nil
          local position = act.pos or mouseover:GetPosition()
          local controlmods = nil
          if self.locomotor == nil then
            self.remote_controls[CONTROL_PRIMARY] = 0
            SendRPCToServer(RPC.LeftClick, act.action.code, position.x, position.z, mouseover, nil, controlmods, act.action.canforce, act.action.mod_name)
          elseif act.action ~= ACTIONS.WALKTO and self:CanLocomote() then
            act.preview_cb = function()
              self.remote_controls[CONTROL_PRIMARY] = 0
              local isreleased = not TheInput:IsControlPressed(CONTROL_PRIMARY)
              SendRPCToServer(RPC.LeftClick, act.action.code, position.x, position.z, mouseover, isreleased, controlmods, nil, act.action.mod_name)
            end
          end
        end

        self:DoAction(act)
        return -- FERTILIZE Action need RPC instead of return bufaction

      end
    end
    return bufaction
  end

  pc.GetActionButtonAction = _fnOver

end

--function PlayerController:DoControllerActionButton()
--    if self.placer ~= nil then
--        --do the placement
--        if self.placer_recipe ~= nil and
--            self.placer.components.placer.can_build and
--            self.inst.replica.builder ~= nil and
--            not self.inst.replica.builder:IsBusy() then
--            self.inst.replica.builder:MakeRecipeAtPoint(self.placer_recipe, self.placer:GetPosition(), self.placer:GetRotation(), self.placer_recipe_skin)
--            self:CancelPlacement()
--        end
--        return
--    end
--
--    local obj = nil
--    local act = nil
--    if self.deployplacer ~= nil then
--        if self.deployplacer.components.placer.can_build then
--            act = self.deployplacer.components.placer:GetDeployAction()
--            if act ~= nil then
--                obj = act.invobject
--                act.distance = 1
--            end
--        end
--    else
--        obj = self:GetControllerTarget()
--        if obj ~= nil then
--            act = self:GetSceneItemControllerAction(obj)
--        end
--    end
--
--    if act == nil then
--        return
--    elseif self.ismastersim then
--        self.inst.components.combat:SetTarget(nil)
--    elseif self.deployplacer ~= nil then
--        if self.locomotor == nil then
--            self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
--            SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.x, act.pos.z, act.rotation ~= 0 and act.rotation or nil)
--        elseif self:CanLocomote() then
--            act.preview_cb = function()
--                self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
--                local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
--                SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.x, act.pos.z, act.rotation ~= 0 and act.rotation or nil, isreleased)
--            end
--        end
--    elseif self.locomotor == nil then
--        self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
--        SendRPCToServer(RPC.ControllerActionButton, act.action.code, obj, nil, act.action.canforce, act.action.mod_name)
--    elseif self:CanLocomote() then
--        act.preview_cb = function()
--            self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
--            local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
--            SendRPCToServer(RPC.ControllerActionButton, act.action.code, obj, isreleased, nil, act.action.mod_name)
--        end
--    end
--
--    self:DoAction(act)
--end

function AutoChores:GetItem(fn)
  local hands = self.INST:inventory_GetEquippedItem(EQUIPSLOTS.HANDS)
  if fn(hands) then
    return hands
  end
  local items = self.INST:inventory_FindItems(fn)
  return items[1]
end
function AutoChores:CustomFindItems( inst, inv, check )
  if not inst or not inv or not check or ( ( not inv.GetItems or not inv:GetItems() ) and not inv.itemslots ) then print("Something went wrong with the inventory...") return nil end
  local items = inv.GetItems and inv:GetItems() or inv.itemslots
  local zeItem = {}

  for k,v in pairs(items) do
    if check(v) then
      table.insert(zeItem,v)
    end
  end

  if inv and inv.GetOverflowContainer then
    items = ( inv:GetOverflowContainer() and inv:GetOverflowContainer().GetItems and inv:GetOverflowContainer():GetItems() ) or ( inv:GetOverflowContainer() and inv:GetOverflowContainer().slots ) or nil
    if items then
      for k,v in pairs(items) do
        if check(v) then
          table.insert(zeItem,v)
        end
      end
    end
  end

  return zeItem
end
function AutoChores:GetInventory( inst )
  return ( inst.components and inst.components.playercontroller and inst.components.inventory ) or ( inst.replica and inst.replica.inventory )
end

function AutoChores:TestHandAction(fn)
  local hands = self.INST:inventory_GetEquippedItem(EQUIPSLOTS.HANDS)
  return fn(hands)
end

function AutoChores:TryActiveItem(fn)
  local activeItem = self.INST:inventory_GetActiveItem()
  if activeItem ~= nil and  fn(activeItem) then
    return activeItem
  end
  local item = self:GetItem(fn)
  if item ~=nil then
    self.INST:inventory_TakeActiveItemFromAllOfSlot(fn)
    return item
  end
end


SEE_DIST_WORK_TARGET = 25
SEE_DIST_LOOT = 5



function AutoChores:GetLumberJackAction()--actions for chopping
  -- print('GetLumberJackAction')

  local item = nil

  local target = FindEntity(self.inst, SEE_DIST_LOOT, function (item)--see if it can find something to pick up
    if item == nil then return false end
    local result = lumberPickup[item.prefab] or false
    if type(result) == "string" then return self.task_flag[result] else return result end
  end)
  if target then
    return BufferedAction(self.inst, target, ACTIONS.PICKUP )--pick it up
  end

  if self.task_flag["shovel"] then
    item = self:GetItem(_isDigger) --get the digger object

    if item == nil then
      local target = FindEntity(self.inst, SEE_DIST_LOOT, _isDigger)--find a digger on the ground
      if target then
        return BufferedAction(self.inst, target, ACTIONS.PICKUP )--pick it up
      end

      local use_gold_tools=(GetModConfigData("use_gold_tools",modname)==1)
      local recipe = "shovel"
      if use_gold_tools then recipe = "goldenshovel" end
      if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
        return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
      else
        local recipe = "shovel"
        if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
          return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
        end
      end
    end

    local digger = item

    if digger  then
      local target = FindEntity(self.inst, SEE_DIST_LOOT, nil, {"stump"})
      if target then
        if self:TestHandAction(_isDigger) == false then --if digger is not equipped
          -- print("do Equip digger", digger)
          return BufferedAction(self.inst, nil, ACTIONS.EQUIP, digger) --equip it
        end
        return BufferedAction(self.inst, target, ACTIONS.DIG, digger ) --otherwise dig the stump
      end
    end
  end

  item = self:GetItem(_isChopper)
  if item == nil then
    local target = FindEntity(self.inst, SEE_DIST_LOOT, _isChopper)--if there is something that can chop on the ground
    if target then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )--pick it up
    end

    local use_gold_tools=(GetModConfigData("use_gold_tools",modname)==1)
    local recipe = "axe"
    if use_gold_tools then recipe = "goldenaxe" end
    if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
      return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
    else
      local recipe = "axe"
      if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
        return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
      end
    end
    return nil
  end
  local chopper = item

  local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item)
    local adult_trees_only=(GetModConfigData("cut_adult_tree_only",modname)==1)
    if item == nil then return false end
    if not item:HasTag("tree") then return false end
    if item:HasTag("burnt") then return self.task_flag["charcoal"] end

    -- adult tree
    if adult_trees_only then
      for ik, iv in ipairs(adultTreeAnims) do
        if item.AnimState:IsCurrentAnimation(iv) then
          return true
        end
      end
      return false
    end

    return true
  end, {"CHOP_workable"})

  if target then
    if self:TestHandAction(_isChopper) == false then
      -- print("do Equip chopper", chopper)
      return BufferedAction(self.inst, nil, ACTIONS.EQUIP, chopper)
    end
    return BufferedAction(self.inst, target, ACTIONS.CHOP, chopper )
  end
end


function AutoChores:GetMinerAction()--actions for mining

  local item = nil

  --pickup target
  local target = FindEntity(self.inst, SEE_DIST_LOOT, function (item)
    if item == nil then return false end
    local result = minerPickup[item.prefab] or false
    if type(result) == "string" then return self.task_flag[result] else return result end
  end)
  if target then
    return BufferedAction(self.inst, target, ACTIONS.PICKUP )
  end

  item = self:GetItem(_isMiner)
  if item == nil then
    local target = FindEntity(self.inst, SEE_DIST_LOOT, _isMiner)
    if target then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    end

    local use_gold_tools=(GetModConfigData("use_gold_tools",modname)==1)
    local recipe = "pickaxe"
    if use_gold_tools then recipe = "goldenpickaxe" end
    if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
      return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
    else
      local recipe = "pickaxe"
      if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
        return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
      end
    end
    return nil
  end
  local minner = item
  --miner target
  if minner then
    local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item)
      if item == nil then return false end
      if item.prefab == "marbleshrub" then -- Marble Shrub
        if self.task_flag["marble"] then
          for ik, iv in ipairs(adultShrub) do
            if item.AnimState:IsCurrentAnimation(iv) then
              return true
            end
          end
      end
      return false
      else -- normal mine
        local result = minerMine[item.prefab] or false
        if item.prefab=="rock_ice" then
          if item._stage:value()==1 then return false end
        end
        if type(result) == "string" then
          if item.prefab=="rock_ice" and self.task_flag[result] then--to avoid mining empty ice
            return item._stage:value()~=1--stage 1 is empty ice boulder
          else
            return self.task_flag[result]
          end
        else return result end
      end
    end, "MINE_workable")
    if target then
      if self:TestHandAction(_isMiner) == false then
        -- print("do Equip digger", digger)
        return BufferedAction(self.inst, nil, ACTIONS.EQUIP, minner)
      end
      return BufferedAction(self.inst, target, ACTIONS.MINE, minner)
    end
  end


end

function AutoChores:GetCollectorAction()
  local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item)
    if item == nil then return false end
    if item:HasTag("pickable") then
      -- pickable
      local result = collectorPick[item.prefab] or false
      if type(result) == "string" then return self.task_flag[result] else return result end
    else
      -- pickup
      local result = collectorPickup[item.prefab] or false
      if type(result) == "string" then return self.task_flag[result] else return result end
    end
  end)
  if target then
    if target:HasTag("pickable") then
      return BufferedAction(self.inst, target, ACTIONS.PICK )
    else
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    end
  end
end


function AutoChores:GetDiggerAction()
  local target = FindEntity(self.inst, SEE_DIST_LOOT, function (item)
    if item == nil then return false end
    local result = diggerPickup[item.prefab] or false
    if type(result) == "string" then return self.task_flag[result] else return result end
  end)
  if target then
    return BufferedAction(self.inst, target, ACTIONS.PICKUP )
  end


  local item = self:GetItem(_isDigger)
  if item == nil then
    local target = FindEntity(self.inst, SEE_DIST_LOOT, _isDigger)
    if target then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    end

    local use_gold_tools=(GetModConfigData("use_gold_tools",modname)==1)
    local recipe = "shovel"
    if use_gold_tools then recipe = "goldenshovel" end
    if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
      return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
    else
      local recipe = "shovel"
      if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
        return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
      end
    end
  end

  local digger = item

  if digger then
    local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item)
      if item == nil then return false end
      local result = diggerDig[item.prefab] or false
      if type(result) == "string" then return self.task_flag[result] else return result end
    end, {"DIG_workable"})

    -- print("target = ", target)
    if target then
      if self:TestHandAction(_isDigger) == false then
        return BufferedAction(self.inst, nil, ACTIONS.EQUIP, digger)
      end
      return BufferedAction(self.inst, target, ACTIONS.DIG, digger )
    end
  end

end

function AutoChores:GetPlanterAction()

  local seed = self:GetItem(function (item)
    if item == nil then return false end
    local result = planterDeploy[item.prefab] or false
    if type(result) == "string" then return self.task_flag[result] else return result end
  end)
  if seed ~= nil then
    if self.task_placer ~= nil then
      for k, placer in pairs(self.task_placer) do
        local pos = placer:GetPosition()
        if Inst(seed):inventoryitem_CanDeploy(pos) then
          return BufferedAction( self.inst, nil, ACTIONS.DEPLOY, seed, pos)
        end
      end
    end
  end
end

function AutoChores:GetFertilizeAction()

  local function _isFertilizer(item)
    if item == nil then return false end
    local result = fertilizeItem[item.prefab] or false
    if type(result) == "string" then return self.task_flag[result] else return result end
  end

  local fertilizer = self.INST:inventory_GetActiveItem()
  if not _isFertilizer(fertilizer) then
    self.INST:inventory_ReturnActiveItem()
    self.INST:inventory_TakeActiveItemFromAllOfSlot(_isFertilizer)
    fertilizer = self.INST:inventory_GetActiveItem()
  end

  if not _isFertilizer(fertilizer) then
    local target = FindEntity(self.inst, SEE_DIST_LOOT, _isFertilizer)
    if target then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    end

    local recipe = "fertilizer"
    if self.task_flag[recipe] then
      if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
        return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
      end
    end
  end

  if fertilizer ~= nil then
    local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item)
      if item == nil then return false end
      return true
    end, nil, {"tree"}, {"withered", "barren"}) -- crop, grower, pickable

    if target then
      --      print("fertilizer = " .. fertilizer.prefab, ", target = " .. target.prefab)
      return BufferedAction( self.inst, target, ACTIONS.FERTILIZE, fertilizer, target:GetPosition())
    end
  end
  self.INST:inventory_ReturnActiveItem()

end

local function _isTrap(item)
  if item == nil then return false end
  return item.prefab == "trap"
end

local function _isTriggeredTrap(item)
  if item == nil or item.prefab ~= "trap" then return false end
  for ik, iv in ipairs(triggeredTrapAnims) do
    if item.AnimState:IsCurrentAnimation(iv) then return true end
  end
  return false
end

local function _isIdleTrap(item)
  if item == nil or item.prefab ~= "trap" then return false end
  return not _isTriggeredTrap(item)
end

local function _needTrapRabbithole(item)
  if item == nil then return false end
  if item.prefab == "rabbithole" then
    return FindEntity(item, 1, _isTrap) == nil
  end
end

function AutoChores:forceDropTrap(pos)
  local trap = self.INST:inventory_GetActiveItem()
  if not _isTrap(trap) then
    self.INST:inventory_ReturnActiveItem()
    self.INST:inventory_TakeActiveItemFromAllOfSlot(_isTrap)
    trap = self.INST:inventory_GetActiveItem()
  end

  if not _isTrap(trap) then
    local recipe = "trap"
    if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
      return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
    end
  end

  return self.INST:GetLeftClickAction(pos, nil)
end

function AutoChores:GetTrapAction()

  local target = nil

  if self.trapOldPos ~= nil then
    local act = self:forceDropTrap(self.trapOldPos)
    if act ~= nil and act.action == ACTIONS.DROP then
      self.trapOldPos = nil
    end
    return act
  end

  target = FindEntity(self.inst, SEE_DIST_LOOT, function (item)
    if item == nil then return false end
    local result = trapPickup[item.prefab] or false
    if type(result) == "string" then return self.task_flag[result] else return result end
  end)
  if target then
    return BufferedAction(self.inst, target, ACTIONS.PICKUP)
  end

  target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function(item)
    if _isTriggeredTrap(item) then
      self.trapOldPos = item:GetPosition()
      return true
    elseif _needTrapRabbithole(item) then
      return self.task_flag["rabbit"]
    end
  end)

  if self.trapOldPos ~= nil then
    return self.INST:GetLeftClickAction(self.trapOldPos, target)
  end

  if target~=nil then
    return self:forceDropTrap(target:GetPosition())
  end
end

return AutoChores
