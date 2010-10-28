local TL, TC, TR = 'TOPLEFT',    'TOP',    'TOPRIGHT'
local ML, MC, MR = 'LEFT',       'CENTER', 'RIGHT'
local BL, BC, BR = 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT'

local nothing = function(...) end

local function unitframes()
  -- move the unitframes to the center of the screen, under the 3d character.
  PlayerFrame:ClearAllPoints()
  PlayerFrame:SetPoint(MR, UIParent, MC, 3.5, -250)
  TargetFrame:ClearAllPoints()
  TargetFrame:SetPoint(ML, UIParent, MC, -3.5, -250)
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

local function minimap()
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
    print(button)
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

local function enable()
  unitframes()
  slashcommands()
  tooltips()
  cvars()
  minimap()
end

event_frame = CreateFrame('Frame')
event_frame:SetScript('OnEvent', function(frame, event, ...)
  if event == 'PLAYER_LOGIN' then
    enable()
  end
end)
event_frame:RegisterEvent('PLAYER_LOGIN')

