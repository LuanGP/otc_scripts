setDefaultTab("News")
local toFollow = storage.toFollow and storage.toFollow or ""
local toFollowPos = {}
UI.TextEdit(storage.toFollow or toFollow, function(widget, newText)
  storage.toFollow = newText
  followMacro:setText("follow "..newText)
end)
local followMacro = macro(20, "follow "..storage.toFollow, function()
  local target = getCreatureByName(storage.toFollow)
  if target then
    local tpos = target:getPosition()
    toFollowPos[tpos.z] = tpos
  end
  local p = toFollowPos[posz()]
  if not p then return end
  if autoWalk(p, 20, {ignoreNonPathable=true, precision=1}) then
    delay(15)
  end
end)
onCreaturePositionChange(function(creature, oldPos, newPos)
  if creature:getName() == storage.toFollow and newPos then
    toFollowPos[newPos.z] = newPos
  end
end)
