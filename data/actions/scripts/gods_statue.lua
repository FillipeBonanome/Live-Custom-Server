-- Statue of a god (see data/lib/400-gods.lua): gives the blessing of the god with that action id.
function onUse(cid, item, fromPosition, itemEx, toPosition)
	local god = Gods.getByActionId(item.actionid)
	if(not god) then
		return false
	end

	return Gods.use(cid, god)
end
