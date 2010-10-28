local TL, TC, TR = 'TOPLEFT',    'TOP',    'TOPRIGHT'
local ML, MC, MR = 'LEFT',       'CENTER', 'RIGHT'
local BL, BC, BR = 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT'

local nothing = function(...) end

local function unitframes()
  -- move the unitframes to the center of the screen, under the 3d character.
  PlayerFrame:ClearAllPoints()
  PlayerFrame:SetPoint(MR, UIParent, MC, 3.5 - 20, -250)
  TargetFrame:ClearAllPoints()
  TargetFrame:SetPoint(ML, UIParent, MC, -3.5 + 20, -250)
  PartyMemberFrame1:ClearAllPoints()
  PartyMemberFrame1:SetPoint(ML, TargetFrame, MR, 0, 100)
  FocusFrame:ClearAllPoints()
  FocusFrame:SetPoint(TC, TargetFrame, BC)

  -- move the castingbar on top of the player and target unitframes
  UIPARENT_MANAGED_FRAME_POSITIONS['CastingBarFrame'] = nil
  CastingBarFrame:ClearAllPoints()
  CastingBarFrame:SetPoint(BC, UIParent, MC, 0, -210)
end

local function slashcommands()
  -- add slash commands for realoding the screen
  SlashCmdList['IDADDON_RELOAD'] = ReloadUI
  SLASH_IDADDON_RELOAD1 = '/rl'
  SLASH_IDADDON_RELOAD2 = '/reload'
end

local function tooltips()
  -- put the tooltip on the mouse
  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, self)
    tooltip:SetOwner(self, 'ANCHOR_CURSOR')
  end)
end

local function cvars()
  -- max out the max cam distance
  SetCVar('cameraDistanceMax', 30)
end

local function maps()
end

local function enable()
  unitframes()
  slashcommands()
  tooltips()
  cvars()
  maps()
end

event_frame = CreateFrame('Frame')
event_frame:SetScript('OnEvent', function(frame, event, ...)
  if event == 'PLAYER_LOGIN' then
    enable()
  end
end)
event_frame:RegisterEvent('PLAYER_LOGIN')

