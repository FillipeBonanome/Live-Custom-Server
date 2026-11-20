local max = 10

function onLogin(cid)
local i = 0
for _, it in ipairs(getPlayersOnline()) do
if getCreatureName(it) == "Account Manager" then
i = i + 1
end

end

if i > max then
return false
end
return true
end