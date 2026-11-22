-- Summon Dragon Skeleton: consumes every summon (4 or more) and raises the Dragon Skeleton, which loses health every second and never heals.
-- While it is alive no other summon can be raised and it cannot be consumed by Soul Sacrifice or Bone Shell.
function onCastSpell(cid, var)
	return Necro.dragon(cid)
end
