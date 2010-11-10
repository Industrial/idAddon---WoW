local MAJOR, MINOR = 'Industrial-1.0', 1
local Industrial = LibStub:NewLibrary(MAJOR, MINOR)

if not Industrial then return end

local nothing = function(...) end

local Frames = {}
Industrial.Frames = Frames
function Frames:Move(f1, p1, f2, p2, x, y, options)
  f1:ClearAllPoints()
  f1:SetPoint(p1, f2, p2, x, y)

  -- from here on inspect options and apply
  if options then
    if options.lock_in_place then
      f1.ClearAllPoints = nothing
      f1.SetPoint = nothing
    end
  end
end

