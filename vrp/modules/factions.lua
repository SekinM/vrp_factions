local cfg = module("cfg/factions")
local factions = cfg.factions

factionMembers = {}

MySQL.createCommand("vRP/get_faction_members","SELECT * FROM vrp_users WHERE faction = @faction")
MySQL.createCommand("vRP/get_user_faction","SELECT * FROM vrp_users WHERE id = @user_id")
MySQL.createCommand("vRP/set_user_faction","UPDATE vrp_users SET faction = @group, factionRank = @rank WHERE id = @user_id")
MySQL.createCommand("vRP/set_faction_leader","UPDATE vrp_users SET isFactionLeader = @leader WHERE id = @user_id")
MySQL.createCommand("vRP/set_faction_coleader","UPDATE vrp_users SET isFactionCoLeader = @coleader WHERE id = @user_id")
MySQL.createCommand("vRP/set_faction_rank","UPDATE vrp_users SET factionRank = @rank WHERE id = @user_id")

MySQL.createCommand("vRP/get_user","SELECT * FROM vrp_users WHERE id = @user_id")

function getFactionMembers()
	for i, v in pairs(factions) do
		MySQL.query("vRP/get_faction_members", {faction = tostring(i)}, function(rows, affected)
			factionMembers[tostring(i)] = rows
		end)
	end
end

AddEventHandler("onResourceStart", function(rs)
	if(rs == "sessionmanager")then
		Citizen.Wait(5000)
		getFactionMembers()
	end
end)

function vRP.getFactions()
	factionsList = {}
	for i, v in pairs(factions) do
		factionsList[i] = v
	end
	return factionsList
end

function vRP.getUserFaction(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		return theFaction
	end
end

function vRP.getFactionRanks(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionRanks = ngroup.fRanks
		return factionRanks
	end
end

function vRP.getFactionRankSalary(faction, rank)
	local ngroup = factions[faction]
	if ngroup then
		local factionRanks = ngroup.fRanks
		for i, v in pairs(factionRanks) do
			if (v.rank == rank)then
				return v.salary - 1
			end
		end
		return 0
	end
end

function vRP.getFactionSlots(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionSlots = ngroup.fSlots
		return factionSlots
	end
end

function vRP.getFactionType(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionType = ngroup.fType
		return tostring(factionType)
	end
end

function vRP.hasUserFaction(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		if(theFaction == "user")then
			return false
		else
			return true
		end
	end
end

function vRP.isUserInFaction(user_id,group)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		if(theFaction == group)then
			return true
		else
			return false
		end
	end
end

function vRP.setFactionLeader(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		tmp.fLeader = 1
		MySQL.execute("vRP/set_faction_leader", {user_id = user_id, leader = 1})
	end
end

function vRP.setFactionCoLeader(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		tmp.fCoLeader = 1
		MySQL.execute("vRP/set_faction_coleader", {user_id = user_id, coleader = 1})
	end
end

function vRP.setFactionNonLeader(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		tmp.fLeader = 0
		MySQL.execute("vRP/set_faction_leader", {user_id = user_id, leader = 0})
	end
end

function vRP.isFactionLeader(user_id,group)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		isLeader = tmp.fLeader
		if(theFaction == group) and (isLeader == 1)then
			return true
		else
			return false
		end
	end
end

function vRP.isFactionCoLeader(user_id,group)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		isCoLeader = tmp.fCoLeader
		if(theFaction == group) and (isCoLeader == 1)then
			return true
		else
			return false
		end
	end
end

function vRP.getFactionRank(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theRank = tmp.fRank
		return theRank
	end
end

function vRP.factionRankUp(user_id)
	local theFaction = vRP.getUserFaction(user_id)
	local actualRank = vRP.getFactionRank(user_id)
	local ranks = factions[theFaction].fRanks
	local tmp = vRP.getUserDataTable(user_id)
	local rankName = tmp.fRank
	for i, v in pairs(ranks) do
		rankTitle = v.rank
		if(rankTitle == rankName)then
			if(i == #ranks)then
				return false
			else
				local theRank = tostring(ranks[i+1].rank)
				tmp.fRank = theRank
				MySQL.execute("vRP/set_faction_rank", {user_id = user_id, rank = theRank})
				return true
			end
		end
	end
end

function vRP.factionRankDown(user_id)
	local theFaction = vRP.getUserFaction(user_id)
	local actualRank = vRP.getFactionRank(user_id)
	local ranks = factions[theFaction].fRanks
	local tmp = vRP.getUserDataTable(user_id)
	local rankName = tmp.fRank
	for i, v in pairs(ranks) do
		rankTitle = v.rank
		if(rankTitle == rankName)then
			if(i == 1)then
				return false
			else
				local theRank = tostring(ranks[i-1].rank)
				tmp.fRank = theRank
				MySQL.execute("vRP/set_faction_rank", {user_id = user_id, rank = tostring(ranks[i-1])})
				return true
			end
		end
	end
end

function vRP.addUserFaction(user_id,theGroup)
	local player = vRP.getUserSource(user_id)
	if (player) then
		local ngroup = factions[theGroup]
		if ngroup then
			local factionRank = ngroup.fRanks[1].rank
			local tmp = vRP.getUserDataTable(user_id)
			if tmp then
				tmp.fName = theGroup
				tmp.fRank = factionRank
				tmp.fLeader = 0
				tmp.fCoLeader = 0
				MySQL.execute("vRP/set_user_faction", {user_id = user_id, group = theGroup, rank = factionRank})
				MySQL.query("vRP/get_user", {user_id = user_id}, function(rows, affected)
					thePlayer = rows[1]
					table.insert(factionMembers[theGroup], thePlayer) 
				end)
			end
		end
	end
end

function vRP.getUsersByFaction(group)
	return factionMembers[group] or {}
end

function vRP.getOnlineUsersByFaction(group)
	local oUsers = {}

	for k,v in pairs(vRP.rusers) do
		if vRP.isUserInFaction(tonumber(k), group) then table.insert(oUsers, tonumber(k)) end
	end

	return oUsers
end

function vRP.removeUserFaction(user_id,theGroup)
	local player = vRP.getUserSource(user_id)
	if (player) then
		local tmp = vRP.getUserDataTable(user_id)
		if tmp then
			for i, v in pairs(factionMembers[theGroup])do
				if (v.id == user_id) then
					-- vRP.tryGetInventoryItem(user_id,"fac_doc|"..theGroup,1,false)
					tmp.fName = "user"
					tmp.fRank = 'none'
					tmp.fLeader = 0
					tmp.fCoLeader = 0
					MySQL.execute("vRP/set_user_faction", {user_id = user_id, group = "user", rank = "none"})
					MySQL.execute("vRP/set_faction_leader", {user_id = user_id, leader = 0})
					MySQL.execute("vRP/set_faction_coleader", {user_id = user_id, coleader = 0})
					table.remove(factionMembers[theGroup], i)
				end
			end
		end
	else
		for i, v in pairs(factionMembers[theGroup])do
			if (v.id == user_id) then
				table.remove(factionMembers[theGroup], i)
				MySQL.execute("vRP/set_user_faction", {user_id = user_id, group = "user", rank = "none"})
				MySQL.execute("vRP/set_faction_leader", {user_id = user_id, leader = 0})
				MySQL.execute("vRP/set_faction_coleader", {user_id = user_id, coleader = 0})
			end
		end
	end
end

-- FACTION MENU
local function ch_leaveGroup(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	local Rank = vRP.getFactionRank(user_id)
	if user_id ~= nil then
		if(vRP.hasUserFaction(user_id))then
			Wait(100)
			vRPclient.notify(player,{"~w~Ai iesit din ~r~"..theFaction.."!"})
			vRP.removeUserGroup(user_id,theFaction)
			Wait(150)
			vRP.removeUserGroup(user_id,Rank)
			vRP.removeUserFaction(user_id,theFaction)
			-- if vRP.hasGroup(user_id,"Politia Romana") or vRP.hasGroup(user_id,"SMURD") or vRP.hasGroup(user_id,"Crips") or vRP.hasGroup(user_id,"Mafia Rusa") or vRP.hasGroup(user_id,"Bloods") or vRP.hasGroup(user_id,"Los Vagos") or vRP.hasGroup(user_id,"Mafia Corleone") or vRP.hasGroup(user_id,"Mafia Siciliana") or vRP.hasGroup(user_id,"Cosa Nostra") or vRP.hasGroup(user_id,"Hitman") then

			-- else
			-- print(nu)
			-- end
		end
		if(vRP.hasGroup(user_id,"onduty"))then
			vRP.removeUserGroup(user_id,"onduty")
		end
		vRP.openMainMenu(player)
	end
end

local function ch_offduty(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil then
		if(vRP.hasUserFaction(user_id))then
			if(vRP.hasGroup(user_id,"onduty"))then
				vRP.removeUserGroup(user_id,"onduty")
			end
			vRPclient.notify(player,{"~r~OFF ~w~Duty in ~b~"..theFaction.."!"})
			TriggerClientEvent('cobrakai', -1, "^1["..theFaction.."]", {0,0,0}, "^1"..GetPlayerName(player).." este Off Duty")
		end
		vRP.openMainMenu(player)
	end
end

local function ch_onduty(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil then
		if(vRP.hasUserFaction(user_id))then
			vRPclient.notify(player,{"~g~ON ~w~Duty in ~b~"..theFaction.."!"})
			vRP.addUserGroup(user_id,"onduty")
			TriggerClientEvent('cobrakai', -1, "^2["..theFaction.."]", {0,0,0}, "^2"..GetPlayerName(player).." este On Duty")
		end
		vRP.openMainMenu(player)
	end
end

local function ch_inviteFaction(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	local members = vRP.getUsersByFaction(theFaction)
	local fSlots = factions[theFaction].fSlots
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) or vRP.isFactionCoLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			if(tonumber(#members) < tonumber(fSlots))then
				local target = vRP.getUserSource(id)
				if(target)then
					local name = GetPlayerName(target)
					if(vRP.hasUserFaction(id))then
						vRPclient.notify(player,{"~r~"..name.." este deja intr-o factiune!"})
						return
					else
						vRPclient.notify(player,{"~w~L-ai adaugat pe ~g~"..name.." ~w~in ~g~"..theFaction.."!"})
						vRPclient.notify(target,{"~w~Ai fost adaugat in ~g~"..theFaction.."!"})
						Citizen.Wait(500)
						vRP.addUserFaction(id,theFaction)
						local Rank = vRP.getFactionRank(id)
						Wait(150)
						vRP.addUserGroup(id,"onduty")
						Wait(150)
						vRP.addUserGroup(id,theFaction)
						Wait(150)
						vRP.addUserGroup(id,Rank)
					end
				else
					vRPclient.notify(player,{"~r~Jucator-ul cu id "..id.." nu este online!"})
				end
			else
				vRPclient.notify(player,{"~r~Nu mai sunt locuri libere: "..fSlots})
			end
		else
			vRPclient.notify(player,{"~r~ID-ul nu este valid"})
			end
		end)
	end
end

local function ch_removeFaction(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	-- local Rank = vRP.getFactionRank(user_id)
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) or vRP.isFactionCoLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
				local target = vRP.getUserSource(id)
				if(target)then
						local name = GetPlayerName(target)
						local Rank = vRP.getFactionRank(id)
						vRPclient.notify(player,{"~w~L-ai scos pe ~g~"..name.." ~w~ din ~g~"..theFaction.."!"})
						vRPclient.notify(target,{"~w~Ai fost dat afara ~g~"..theFaction.."!"})
						vRP.removeUserGroup(id,theFaction)
						Wait(150)
						vRP.removeUserGroup(id,Rank)
						vRP.removeUserFaction(id,theFaction)
						Wait(150)
						if(vRP.hasGroup(id,"onduty"))then
							vRP.removeUserGroup(id,"onduty")
						end
				else
					vRPclient.notify(player,{"~w~l-ai scos pe ID: ~g~"..id.." ~w~din ~g~"..theFaction.."!"})
					vRP.removeUserFaction(id,theFaction)
				end
			else
				vRPclient.notify(player,{"~r~ID-ul nu este valid"})
			end
		end)
	end
end

local function ch_promoteLeader(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) or vRP.isFactionCoLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			local target = vRP.getUserSource(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			if(target)then
				local name = GetPlayerName(target)
				if(vRP.isUserInFaction(id,theFaction))then
					if(vRP.isFactionLeader(id,theFaction))then
						vRPclient.notify(player,{"~w~Ai retrogradat pe ~g~"..name.." ~w~la ~g~Membru!"})
						vRPclient.notify(target,{"~w~Ai fost retrogradat la ~g~Membru ~w~in ~g~"..theFaction.."!"})
						vRP.setFactionNonLeader(id)
						Wait(450)
						vRP.openMainMenu(player)
					else
						vRPclient.notify(player,{"~w~Ai promovat pe ~g~"..name.." ~w~la ~g~Leader!"})
						vRPclient.notify(player,{"~w~Nu mai esti Leader ~g~pentru ca l-ai dat la altcineva!"})
						vRPclient.notify(target,{"~w~Ai fost promovat la ~g~Leader ~w~in ~g~"..theFaction.."!"})
						vRP.setFactionLeader(id)
						vRP.setFactionNonLeader(user_id)
						Wait(450)
						vRP.openMainMenu(player)
					end
				else
					vRPclient.notify(player,{"~w~Jucator-ul ~g~"..name.." ~w~nu este membru din:  ~g~"..theFaction.."!"})
				end
			else
				vRPclient.notify(player,{"~r~Jucator-ul cu id : "..id.." nu este online!"})
			end
		else
			vRPclient.notify(player,{"~r~ID-ul nu este valid!"})
			end
		end)
	end
end

local function ch_promoteCoLeader(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil and vRP.isFactionCoLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			local target = vRP.getUserSource(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			if(target)then
				local name = GetPlayerName(target)
				if(vRP.isUserInFaction(id,theFaction))then
					if(vRP.isFactionCoLeader(id,theFaction))then
						vRPclient.notify(player,{"~w~You have been downgraded ~g~"..name.." ~w~at ~g~Member!"})
						vRPclient.notify(target,{"~w~You have been downgraded at ~g~Member ~w~in faction ~g~"..theFaction.."!"})
						vRP.setFactionNonCoLeader(id)
						Wait(450)
						vRP.openMainMenu(player)
					else
						vRPclient.notify(player,{"~w~You Promote ~g~"..name.." ~w~at ~g~Leader!"})
						vRPclient.notify(player,{"~w~Your Leader Function has been removed ~g~because you added another leader!"})
						vRPclient.notify(target,{"~w~You have been promote at  ~g~Leader ~w~in faction ~g~"..theFaction.."!"})
						vRP.setFactionCoLeader(id)
						vRP.setFactionNonCoLeader(user_id)
						Wait(450)
						vRP.openMainMenu(player)
					end
				else
					vRPclient.notify(player,{"~w~The player ~g~"..name.." ~w~is not member in faction:  ~g~"..theFaction.."!"})
				end
			else
				vRPclient.notify(player,{"~r~The player with "..id.."is not online!"})
			end
		else
			vRPclient.notify(player,{"~r~Seems Valid ID"})
			end
		end)
	end
end

local function ch_promoteMember(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			local target = vRP.getUserSource(id)
			if(target)then
				local name = GetPlayerName(target)
				if(vRP.isUserInFaction(id,theFaction))then
					local oldRank = vRP.getFactionRank(id)
					if(vRP.factionRankUp(id))then
						SetTimeout(1000, function()
							local newRank = vRP.getFactionRank(id)
							vRPclient.notify(player,{"~w~L-ai promovat pe ~g~"..name.." ~w~de la ~r~"..oldRank.." ~w~la ~g~"..newRank.."!"})
							vRPclient.notify(target,{"~w~Ai fost promovat de la ~r~"..oldRank.." ~w~la~g~ "..newRank.." ~w~in factiunea ~g~"..theFaction.."!"})
							vRP.removeUserGroup(id,oldRank)
							vRP.addUserGroup(id,newRank)
						end)
					else
						vRPclient.notify(player,{"~g~"..name.." ~w~este deja cel mai mare rank!"})
					end
				else
					vRPclient.notify(player,{"~w~Jucator-ul ~g~"..name.." ~w~nu este membru din:  ~g~"..theFaction.."!"})
				end
			else
				vRPclient.notify(player,{"~r~Jucator-ul cu id : "..id.." nu este online!"})
			end
		else
			vRPclient.notify(player,{"~r~ID-ul nu este valid!"})
			end
		end)
	end
end

local function ch_demoteMember(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			local target = vRP.getUserSource(id)
			if(target)then
				local name = GetPlayerName(target)
				if(vRP.isUserInFaction(id,theFaction))then
					local oldRank = vRP.getFactionRank(id)
					if(vRP.factionRankDown(id))then
						SetTimeout(1000, function()
							local newRank = vRP.getFactionRank(id)
							vRPclient.notify(player,{"~w~L-ai retrogradat pe ~g~"..name.." ~w~de la ~r~"..oldRank.." ~w~la ~g~"..newRank.."!"})
							vRPclient.notify(target,{"~w~Ai fost retrogradat de la ~r~"..oldRank.." ~w~la~g~"..newRank.." ~w~in factiunea ~g~"..theFaction.."!"})
							vRP.removeUserGroup(id,oldRank)
							vRP.addUserGroup(id,newRank)
						end)
					else
						vRPclient.notify(player,{"~g~"..name.." ~w~este deja cel mai mic rank!"})
					end
				else
					vRPclient.notify(player,{"~w~Jucator-ul ~g~"..name.." ~w~nu este membru din:  ~g~"..theFaction.."!"})
				end
			else
				vRPclient.notify(player,{"~r~Jucator-ul cu id : "..id.." nu este online!"})
			end
		else
			vRPclient.notify(player,{"~r~ID-ul nu este valid!"})
			end
		end)
	end
end

local function ch_memberList(player,choice)
	return true
end

local function ch_membersList(player,choice)
	vRP.openMainMenu(player)
	player = player
	SetTimeout(400, function()
		vRP.buildMenu("Membri", {player = player}, function(menu2)
			menu2.name = "Membri"
			menu2.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			menu2.onclose = function(player) vRP.openMainMenu(player) end
			local user_id = vRP.getUserId(player)
			local theFaction = vRP.getUserFaction(user_id)
			local members = vRP.getUsersByFaction(theFaction)
			for i, v in pairs(members) do
				if(v.isFactionLeader == 1)then
					isMLeader = "Leader"
				elseif(v.isFactionCoLeader == 1)then
					isMLeader = "Co-Leader"
				else
					isMLeader = "Membru"
				end
				local userID = v.id
				local rank = v.factionRank
				local lLogin = v.last_login
				lastLogin = {}
				for lasLogin in lLogin:gmatch("%S+") do
				   table.insert(lastLogin, lasLogin)
				end
				menu2[v.username] = {ch_memberList, "ID: <font color='yellow'>"..userID.."</font><br/>Rank: <font color='yellow'>"..rank.."</font><br/>Status: <font color='green'>"..isMLeader.."</font><br/>Ultima Conectare: <font color='red'>"..lastLogin[3].."</font>"}
			end
			vRP.openMenu(player,menu2)
		end)
	end)
end

local function ch_leaveFaction(player,choice)
	vRP.openMainMenu(player)
	player = player
	SetTimeout(400, function()
		vRP.buildMenu("Esti Sigur?", {player = player}, function(menu1)
			menu1.name = "Esti Sigur?"
			menu1.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			menu1.onclose = function(player) vRP.openMainMenu(player) end
			menu1["Da"] = {ch_leaveGroup, "Iesi din factiune"}
			menu1["Nu"] = {function(player) vRP.openMainMenu(player) end}
			vRP.openMenu(player,menu1)
		end)
	end)
end

local function ch_Off_Duty(player,choice)
	vRP.openMainMenu(player)
	player = player
	SetTimeout(400, function()
		vRP.buildMenu("Esti Sigur?", {player = player}, function(menu1)
			menu1.name = "Esti Sigur?"
			menu1.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			menu1.onclose = function(player) vRP.openMainMenu(player) end
			menu1["Da"] = {ch_offduty, "Pune-te Off Duty"}
			menu1["Nu"] = {function(player) vRP.openMainMenu(player) end}
			vRP.openMenu(player,menu1)
		end)
	end)
end

local function ch_On_Duty(player,choice)
	vRP.openMainMenu(player)
	player = player
	SetTimeout(400, function()
		vRP.buildMenu("Esti Sigur?", {player = player}, function(menu1)
			menu1.name = "Esti Sigur?"
			menu1.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			menu1.onclose = function(player) vRP.openMainMenu(player) end
			menu1["Da"] = {ch_onduty, "Pune-te On Duty"}
			menu1["Nu"] = {function(player) vRP.openMainMenu(player) end}
			vRP.openMenu(player,menu1)
		end)
	end)
end

local function ch_dummySalary(player,choice)
	return false
end

local function ch_ranksAndSalary(player,choice)
	vRP.openMainMenu(player)
	player = player
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	local ranks = vRP.getFactionRanks(theFaction)
	SetTimeout(400, function()
		vRP.buildMenu("Grade si Salarii", {player = player}, function(rsMenu)
			rsMenu.name = "Grade si Salarii"
			rsMenu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			rsMenu.onclose = function(player) vRP.openMainMenu(player) end
			for i, v in pairs(ranks) do
				facRank = v.rank
				local salary = vRP.getFactionRankSalary(theFaction, facRank)
				rsMenu["["..i.."] "..facRank] = {ch_dummySalary, "Salariu: <font color='green'>$"..salary.."</font>"}
			end
			vRP.openMenu(player,rsMenu)
		end)
	end)
end

vRP.registerMenuBuilder("main", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
		local choices = {}
		local tmp = vRP.getUserDataTable(user_id)
		if tmp then
			if(vRP.hasUserFaction(user_id))then
				local theFaction = vRP.getUserFaction(user_id)
				local rank = vRP.getFactionRank(user_id)
				local leader = vRP.isFactionLeader(user_id,theFaction)
				local coleader = vRP.isFactionCoLeader(user_id,theFaction)
				local members = vRP.getUsersByFaction(theFaction)
				local fType = vRP.getFactionType(theFaction)
				local fSlots = vRP.getFactionSlots(theFaction)
				local salary = vRP.getFactionRankSalary(theFaction, rank) or 0
				if(leader)then
					isLeader = "Leader"
				elseif(coleader)then
					isLeader = "Co-Leader"
				else
					isLeader = "Membru"
				end
				if(vRP.hasGroup(user_id,"onduty"))then
					Duty = "ON"
				else
					Duty = "OFF"
				end
				if(salary > 0)then
					if(#members == fSlots)then
						infoText = "Name: <font color='red'>"..theFaction.."</font><br/>Members: <font color='red'>"..#members.."</font>/<font color='red'>"..fSlots.."</font><br/></font><br/>Rank: <font color='grey'>"..rank.."</font><br/>Duty: <font color='green'>"..Duty.."</font><br/>Salary: <font color='green'>$"..salary.."</font><br/>Statut: <font color='yellow'>"..isLeader.."</font>"
					else
						infoText = "Name: <font color='red'>"..theFaction.."</font><br/>Members: <font color='white'>"..#members.."</font>/<font color='red'>"..fSlots.."</font><br/></font><br/>Rank: <font color='grey'>"..rank.."</font><br/>Duty: <font color='red'>"..Duty.."</font><br/>Salary: <font color='green'>$"..salary.."</font><br/>Statut: <font color='yellow'>"..isLeader.."</font>"
					end
				else
					if(#members == fSlots)then
						infoText = "Name: <font color='red'>"..theFaction.."</font><br/>Members: <font color='red'>"..#members.."</font>/<font color='red'>"..fSlots.."</font><br/><br/>Rank: <font color='grey'>"..rank.."</font><br/>Status: <font color='blue'>"..isLeader.."</font>"
					else
						infoText = "Name: <font color='red'>"..theFaction.."</font><br/>Members: <font color='yellow'>"..#members.."</font>/<font color='red'>10</font><br/><br/>Rank: <font color='grey'>"..rank.."</font><br/>Status: <font color='blue'>"..isLeader.."</font>"	
					end
				end
				choices["Meniu Factiune"] = {function(player,choice)
					vRP.buildMenu(theFaction, {player = player}, function(menu,ok)
						menu.name = theFaction
						menu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
						menu.onclose = function(player) vRP.openMainMenu(player) end -- nest menu
						if(leader or coleader)then
							menu["Invita Jucator"] = {ch_inviteFaction, "Invita un jucator in factiune"}
							menu["Scoate Din Factiune"] = {ch_removeFaction, "Scoate un membru din factiune"}
							menu["Promoveaza Leader"] = {ch_promoteLeader, "Promoveaza/Retrogradeaza un jucator la Leader/Membru"}
						end
						if(leader)then
							menu["Promoveaza Membru"] = {ch_promoteMember, "Promoveaza un jucator la grad-ul superior"}
							menu["Retrogradare Membru"] = {ch_demoteMember, "Retrogradeaza un jucator la grad-ul inferior"}
						end
						if(coleader)then
							menu["Promoveaza Co-Leader"] = {ch_promoteCoLeader, "Promoveaza/Retrogradeaza un jucator la Co-Leader/Membru"}
						end
						if(fType == "Lege")then
						if(vRP.hasGroup(user_id,"onduty"))then
							menu["Mode Off Duty"] = {ch_Off_Duty, "Pune-te Off Duty in "..theFaction}
						else
							menu["Mode On Duty"] = {ch_On_Duty, "Pune-te On Duty in "..theFaction}
						end
						end
						menu["Membri"] = {ch_membersList, "Membri la "..theFaction}
						menu["Grade si Salarii"] = {ch_ranksAndSalary, "Rankuri si Salarii"}
						menu["Iesi din factiune"] = {ch_leaveFaction, "Iesi din factiunea "..theFaction}
						vRP.openMenu(player,menu)
					end)
				end, infoText}
			end
		end
		add(choices)
	end
end)

AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		MySQL.query("vRP/get_user_faction", {user_id = user_id}, function(rows, affected)
			theFaction = tostring(rows[1].faction)
			isLeader = tonumber(rows[1].isFactionLeader)
			factionRank = tostring(rows[1].factionRank)
			tmp.fName = theFaction
			tmp.fRank = factionRank
			tmp.fLeader = isLeader
			tmp.fCoLeader = isCoLeader
		end)
	end
end)

local function ch_addfaction(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"User id: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			vRP.prompt(player,"Faction: ","",function(player,group)
				group = tostring(group)
				if(group ~= "") and (group ~= nil)then
				vRP.prompt(player,"Leader(1), Co-Leader(2), Member(0): ","",function(player,lider)
					lider = parseInt(lider)
					theTarget = vRP.getUserSource(id)
					if(tonumber(lider)) and (lider == 0 or lider == 1 or lider == 2) and (lider ~= "") and (lider ~= nil)then
					local name = GetPlayerName(theTarget)
					if(lider == 1) then
						vRP.addUserFaction(id,group)
						local Rank = vRP.getFactionRank(user_id)
						vRP.addUserGroup(id,"onduty")
						Citizen.Wait(500)
						vRP.addUserGroup(id,theFaction)
						Citizen.Wait(500)
						vRP.addUserGroup(id,Rank)
						Citizen.Wait(500)
						vRP.setFactionLeader(id,group)
						vRPclient.notify(player,{"Jucatorul "..name.."  a fost adaugat ca si Leader in factiunea "..group})
						return
					elseif(lider == 2) then
						vRP.addUserFaction(id,group)
						vRP.addUserGroup(id,"onduty")
						local Rank = vRP.getFactionRank(user_id)
						vRP.addUserGroup(id,"onduty")
						Citizen.Wait(500)
						vRP.addUserGroup(id,theFaction)
						Citizen.Wait(500)
						vRP.addUserGroup(id,Rank)
						Citizen.Wait(500)
						vRP.setFactionCoLeader(id,group)
						vRPclient.notify(player,{"Jucatorul "..name.."  a fost adaugat ca si Co-Leader in factiunea "..group})
						return
					else
						vRP.addUserFaction(id,group)
						vRP.addUserGroup(id,"onduty")
						Citizen.Wait(500)
						vRP.addUserGroup(id,group)
						local Rank = vRP.getFactionRank(user_id)
						vRP.addUserGroup(id,"onduty")
						Citizen.Wait(500)
						vRP.addUserGroup(id,theFaction)
						Citizen.Wait(500)
						vRP.addUserGroup(id,Rank)
						vRPclient.notify(player,{"Jucatorul "..name.." a fost adaugat in factiunea "..group})
					end
				else
					vRPclient.notify(player,{"~r~Try to put 1 or 0 to choose the Leader or not!"})
					end
				end)
			else
				vRPclient.notify(player,{"~r~The Factions is invalid!"})
				end
			end)
		else
			vRPclient.notify(player,{"~r~Seems Valid ID"})
			end
		end)
	end
end

local function ch_removefaction(player,choice)
	local user_id = vRP.getUserId(player)
	local Rank = vRP.getFactionRank(user_id)
	if user_id ~= nil then
		vRP.prompt(player,"User id: ","",function(player,id)
			id = parseInt(id)
			theTarget = vRP.getUserSource(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			local name = GetPlayerName(theTarget)
			theFaction = vRP.getUserFaction(id)
			if(theFaction == "user")then
				vRPclient.notify(player,{"Jucatorul cu ID-ul "..id.." nu este intr-o factiune"})
			else
				vRP.removeUserGroup(id,theFaction)
				vRP.removeUserGroup(id,Rank)
				vRP.removeUserFaction(id,theFaction)
				vRP.removeUserGroup(id,"onduty")
				vRPclient.notify(player,{theFaction.." removed from user "..id})
			end
		else
			vRPclient.notify(player,{"~r~Seems Valid ID"})
			end
		end)
	end
end

local function ch_factionleader(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"User id: ","",function(player,id)
			id = parseInt(id)
			theTarget = vRP.getUserSource(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			local name = GetPlayerName(theTarget)
			local theFaction = vRP.getUserFaction(id)
			if(theFaction == "user")then
				vRPclient.notify(player,{"Jucatorul cu ID-ul "..name.." nu este in nici o factiune!"})
			else
				vRP.setFactionLeader(id,theFaction)
				vRPclient.notify(player,{"Jucatorul cu ID-ul "..name.." a fost adaugat ca ~y~Lider ~w~in factiunea "..theFaction})
			end
		else
			vRPclient.notify(player,{"~r~Seems Valid ID"})
			end
		end)
	end
end

local function ch_factioncoleader(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"User id: ","",function(player,id)
			id = parseInt(id)
			theTarget = vRP.getUserSource(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			local name = GetPlayerName(theTarget)
			local theFaction = vRP.getUserFaction(id)
			if(theFaction == "user")then
				vRPclient.notify(player,{"The Player with ID "..name.." it is not in any faction !"})
			else
				vRP.setFactionCoLeader(id,theFaction)
				vRPclient.notify(player,{"The Player with ID "..name.." was added that ~y~Co-Leader ~w~to the Faction "..theFaction})
			end
		else
			vRPclient.notify(player,{"~r~Seems Valid ID"})
			end
		end)
	end
end

vRP.registerMenuBuilder("admin", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
		local choices = {}
		if vRP.hasGroup(user_id,"admin") then
			choices["Add Factions"] = {ch_addfaction}
			choices["Add Leader Factions"] = {ch_factionleader}
			choices["Add Co-Leader Factions"] = {ch_factioncoleader}
			choices["Remove from Factions"] = {ch_removefaction}
		end
		add(choices)
	end
end)
