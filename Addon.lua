local LibStub = _G.LibStub
local Industrial = LibStub('Industrial-1.0')
local AceAddon = LibStub('AceAddon-3.0')
local AceDB = LibStub('AceDB-3.0')
local AceDBOptions = LibStub('AceDBOptions-3.0')
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local TL, TC, TR = 'TOPLEFT',    'TOP',    'TOPRIGHT'
local ML, MC, MR = 'LEFT',       'CENTER', 'RIGHT'
local BL, BC, BR = 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT'

local ADDON_NAME = 'idAddon'
local OPTIONS
local DB

local Addon = AceAddon:NewAddon(ADDON_NAME)

function Addon:OnInitialize()
  DB = AceDB:New('idAddonDB', {
    profile = {
      modules = {
        unitframes = {
          x = 0,
          y = 300
        }
      }
    }
  }, true)

  OPTIONS = {
    type = 'group',
    args = {
      profiles = AceDBOptions:GetOptionsTable(DB),
      modules = {
        type = 'group',
        name = 'Modules',
        args = {}
      }
    }
  }

  AceConfig:RegisterOptionsTable(ADDON_NAME, OPTIONS, {'idaddon', 'id'})
  AceConfigDialog:AddToBlizOptions(ADDON_NAME)
end

function Addon:OnDisable()
end

local SlashcommandsModule = Addon:NewModule('Slashcommands')
function SlashcommandsModule:Enable()
  -- add slash commands for realoding the screen
  SlashCmdList['IDADDON_RELOAD'] = ReloadUI
  SLASH_IDADDON_RELOAD1 = '/rl'
end

function SlashcommandsModule:Disable()
  SlashCmdList['IDADDON_RELOAD'] = nil
  SLASH_IDADDON_RELOAD1 = nil
end

local TooltipsModule = Addon:NewModule('Tooltips', 'AceHook-3.0')
function TooltipsModule:OnEnable()
  -- put the tooltip on the mouse
  self:Hook('GameTooltip_SetDefaultAnchor', function(tooltip, self)
    tooltip:SetOwner(self, 'ANCHOR_CURSOR')
  end, true)
end

function TooltipsModule:OnDisable()
  self:Unhook('GameTooltip_SetDefaultAnchor')
end

local CVarsModule = Addon:NewModule('CVars')
function CVarsModule:OnEnable()
  SetCVar('cameraDistanceMax', 30)
end

local UnitframesModule = Addon:NewModule('Unitframes')
function UnitframesModule:OnEnable()
  OPTIONS.args.modules.args.unitframes = {
    type = 'group',
    name = 'Unitframes',
    args = {
      x = {
        name = 'x',
        desc = 'horizontal position from the center of the screen',
        type = 'range',
        min = 0,
        max = 500,
        get = function(f)
          return DB.profile.modules.unitframes.x
        end,
        set = function(f, v)
          DB.profile.modules.unitframes.x = v
          self:Update()
        end,
      },
      y = {
        name = 'y',
        desc = 'vertical position from the center of the screen',
        type = 'range',
        min = -500,
        max = 500,
        get = function(f)
          return DB.profile.modules.unitframes.y
        end,
        set = function(f, v)
          DB.profile.modules.unitframes.y = v
          self:Update()
        end,
      },
    }
  }
  local db = DB.profile.modules.unitframes

  self:Update()

  PartyMemberFrame1:ClearAllPoints()
  PartyMemberFrame1:SetPoint(ML, TargetFrame, MR, 0, 100)
  FocusFrame:ClearAllPoints()
  FocusFrame:SetPoint(TC, TargetFrame, BC)

  -- move the castingbar on top of the player and target unitframes
  --[[UIPARENT_MANAGED_FRAME_POSITIONS['CastingBarFrame'] = nil
  CastingBarFrame:ClearAllPoints()
  CastingBarFrame:SetPoint(MC, UIParent, MC, 0, -db.y + 20)]]
end

function UnitframesModule:OnDisable()
end

function UnitframesModule:Update()
  local db = DB.profile.modules.unitframes
  PlayerFrame:ClearAllPoints()
  PlayerFrame:SetPoint(MR, UIParent, MC, -db.x + 3.5, -db.y)
  TargetFrame:ClearAllPoints()
  TargetFrame:SetPoint(ML, UIParent, MC, db.x - 3.5, -db.y)
end

local MinimapModule = Addon:NewModule('Minimap')
function MinimapModule:OnEnable()
  local function zoomMinimap(frame, delta)
    if delta > 0 and Minimap:GetZoom() < 5 then
      Minimap:SetZoom(Minimap:GetZoom() + 1)
    elseif delta < 0 and Minimap:GetZoom() > 0 then
      Minimap:SetZoom(Minimap:GetZoom() - 1)
    end
  end

  Minimap:EnableMouseWheel(true)
  Minimap:SetScript('OnMouseWheel', zoomMinimap)
  Minimap:SetScript('OnMouseUp', function(frame, button, ...)
    if button == 'RightButton' then
      MiniMapTrackingButton:GetScript('OnClick')()
    else
      Minimap_OnClick(Minimap)
    end
  end)

  Industrial.Frames:Move(MinimapCluster, MR, PlayerFrame, ML, 0, 0)
  Industrial.Frames:Move(WatchFrameCollapseExpandButton, TL, UIParent, TL, 1, -1)
  Industrial.Frames:Move(WatchFrameHeader, ML, WatchFrameCollapseExpandButton, MR, 5, -2)
  Industrial.Frames:Move(WatchFrame, TL, WatchFrameCollapseExpandButton, BL, 30, 25, {lock_in_place=true})
  Industrial.Frames:Move(MiniMapLFGFrame, MC, MinimapCluster, TC, 10, -20)
  Industrial.Frames:Move(DurabilityFrame, TR, UIParent, TR, 0, -25)

  -- hide minimap elements
  GameTimeFrame:Hide() -- calendar
  TimeManagerClockButton:Hide()
  MiniMapTracking:Hide()
  MinimapBorderTop:Hide()
  MiniMapWorldMapButton:Hide()
  MiniMapVoiceChatFrame:Hide()
  MiniMapVoiceChatFrame:SetScript('OnShow', MiniMapVoiceChatFrame.Hide)
  MiniMapWorldMapButton:Hide()
  MinimapZoneTextButton:Hide()
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
end

function MinimapModule:OnDisable()
end

local BuffRelocationModule = Addon:NewModule('BuffRelocations')
function BuffRelocationModule:OnEnable()
  Industrial.Frames:Move(BuffFrame, TR, UIParent, TR, -1, -2, {lock_in_place=true})
  Industrial.Frames:Move(ConsolidatedBuffs, TR, UIParent, TR, -1, -12, {lock_in_place=true})
end

function BuffRelocationModule:OnDisable()
end

local FrameMoverModule = Addon:NewModule('FrameMover', 'AceEvent-3.0')
local POINT_SETTINGS = {
  ['TOPLEFT'] = 'TOPLEFT',
  ['TOP'] = 'TOP',
  ['TOPRIGHT'] = 'TOPRIGHT',
  ['LEFT'] = 'LEFT',
  ['CENTER'] = 'CENTER',
  ['BOTTOMLEFT'] = 'BOTTOMLEFT',
  ['BOTTOM'] = 'BOTTOM',
  ['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
}

function FrameMoverModule:AddFrame(frame)
  local name = frame:GetName()
  local p1, f2, p2, x, y = frame:GetPoint()

  if self.db.frames[name] then
    return
  end

  self.db.frames[name] = {
    p1 = p1,
    f2 = f2,
    p2 = p2,
    x = x,
    y = y,
  }
  self.options.args.frames.args[name] = {
    type = 'group',
    name = name,
    args = {
      p1 = {
        type = 'select',
        style = 'radio',
        name = 'p1',
        desc = 'point for this frame',
        values = POINT_SETTINGS,
        get = function(f)
          return self.db.frames[name].p1
        end,
        set = function(f, v)
          self.db.frames[name].p1 = v
        end,
      },
      f2 = {
        type = 'input',
        name = 'f2',
        desc = 'name of other frame',
        get = function(f)
          return self.db.frames[name].f2
        end,
        set = function(f, v)
          self.db.frames[name].f2 = v
        end,
      },
      p2 = {
        type = 'select',
        style = 'radio',
        name = 'p2',
        desc = 'point for other frame',
        values = POINT_SETTINGS,
        get = function(f)
          return self.db.frames[name].p2
        end,
        set = function(f, v)
          self.db.frames[name].p2 = v
        end,
      },
      x = {
        type = 'range',
        name = 'x',
        desc = 'horizontal offset',
        min = -500,
        max = 500,
        get = function(f)
          return self.db.frames[name].x
        end,
        set = function(f, v)
          self.db.frames[name].x = v
        end,
      },
      y = {
        type = 'range',
        name = 'y',
        desc = 'vertical offset',
        min = -500,
        max = 500,
        get = function(f)
          return self.db.frames[name].x
        end,
        set = function(f, v)
          self.db.frames[name].x = v
        end,
      },
    }
  }
end

function FrameMoverModule:RemoveFrame(frame)
  local name = frame:GetName()
  self.db.frames[name] = nil
  self.options.args.frames.args[name] = nil
end

function FrameMoverModule:OnEnable()
  self.db = DB.profile.modules.framemover
  self.options = {
    type = 'group',
    name = 'Frame Mover',
    args = {
      addremove_frames = {
        type = 'group',
        name = 'Add & Remove',
        args = {
          add = {
            type = 'input',
            name = 'add',
            desc = 'Add frames',
            validate = function(f, name)
              local frame = _G[name]
              if not frame then
                return ('Frame \'%s\' does not exist.'):format(name)
              end
            end
          }
        }
      },
      frames = {
        type = 'group',
        name = 'Frames',
        args = {
        }
      }
    }
  }
  OPTIONS.args.modules.args.framemover = self.options

  local db = DB.profile.modules.unitframes
end

_G[ADDON_NAME] = Addon

