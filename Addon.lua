local LibStub = _G.LibStub
local AceAddon = LibStub('AceAddon-3.0')
local AceDB = LibStub('AceDB-3.0')
local AceDBOptions = LibStub('AceDBOptions-3.0')
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local TL, TC, TR = 'TOPLEFT',    'TOP',    'TOPRIGHT'
local ML, MC, MR = 'LEFT',       'CENTER', 'RIGHT'
local BL, BC, BR = 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT'

local ADDON_NAME = 'idAddon'

local nothing = function(...) end

local Addon = AceAddon:NewAddon(ADDON_NAME)

local defaults = {
  profile = {
    unitframes = {
      x = 0,
      y = 300
    }
  }
}

function Addon:enableUnitframes()
  local db = self.db.profile.unitframes

  self:updateUnitframes()

  PartyMemberFrame1:ClearAllPoints()
  PartyMemberFrame1:SetPoint(ML, TargetFrame, MR, 0, 100)
  FocusFrame:ClearAllPoints()
  FocusFrame:SetPoint(TC, TargetFrame, BC)

  -- move the castingbar on top of the player and target unitframes
  --[[UIPARENT_MANAGED_FRAME_POSITIONS['CastingBarFrame'] = nil
  CastingBarFrame:ClearAllPoints()
  CastingBarFrame:SetPoint(MC, UIParent, MC, 0, -db.y + 20)]]
end

function Addon:updateUnitframes()
  local db = self.db.profile.unitframes
  PlayerFrame:ClearAllPoints()
  PlayerFrame:SetPoint(MR, UIParent, MC, -db.x + 3.5, -db.y)
  TargetFrame:ClearAllPoints()
  TargetFrame:SetPoint(ML, UIParent, MC, db.x - 3.5, -db.y)
end

function Addon:enableSlashcommands()
  -- add slash commands for realoding the screen
  SlashCmdList['IDADDON_RELOAD'] = ReloadUI
  SLASH_IDADDON_RELOAD1 = '/rl'
end

function Addon:enableTooltips()
  -- put the tooltip on the mouse
  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, self)
    tooltip:SetOwner(self, 'ANCHOR_CURSOR')
  end)
end

function Addon:enableCvars()
  -- max out the max cam distance
  SetCVar('cameraDistanceMax', 30)
end

function Addon:enableMinimap()
  local function process(f1, p1, f2, p2, x, y, make_unmovable)
    make_unmovable = make_unmovable == false and false or true

    f1:ClearAllPoints()
    f1:SetPoint(p1, f2, p2, x, y)

    if make_unmovable then
      f1.ClearAllPoints = nothing
      f1.SetPoint = nothing
    end
  end

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

  process(MinimapCluster, MR, PlayerFrame, ML, 0, 0)
  process(WatchFrameCollapseExpandButton, TL, UIParent, TL, 5, -20)
  process(WatchFrameHeader, ML, WatchFrameCollapseExpandButton, MR, 5, -2)
  process(WatchFrame, TL, WatchFrameCollapseExpandButton, BL, 25, 25)
  process(MiniMapLFGFrame, MC, MinimapCluster, TC, 10, -20)
  process(DurabilityFrame, TR, UIParent, TR, 0, -25)

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

function Addon:OnInitialize()
  self.db = AceDB:New('idAddonDB', defaults, true)

  local options = {
    type = 'group',
    args = {
      profiles = AceDBOptions:GetOptionsTable(self.db),
      unitframes = {
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
              return self.db.profile.unitframes.x
            end,
            set = function(f, v)
              self.db.profile.unitframes.x = v
              self:updateUnitframes()
            end,
          },
          y = {
            name = 'y',
            desc = 'vertical position from the center of the screen',
            type = 'range',
            min = -500,
            max = 500,
            get = function(f)
              return self.db.profile.unitframes.y
            end,
            set = function(f, v, ...)
              print(f, v, ...)
              self.db.profile.unitframes.y = v
              self:updateUnitframes()
            end,
          },
        }
      },
    }
  }

  AceConfig:RegisterOptionsTable(ADDON_NAME, options, {'idaddon', 'id'})
  AceConfigDialog:AddToBlizOptions(ADDON_NAME)
end

function Addon:OnEnable()
  self:enableUnitframes()
  self:enableSlashcommands()
  self:enableTooltips()
  self:enableCvars()
  self:enableMinimap()
end

function Addon:OnDisable()
end

_G[ADDON_NAME] = Addon

