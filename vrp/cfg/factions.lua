local cfg = {}

cfg.factions = {
---911----
   ["SMURD"] = {
		fType = "Lege", --Type 'Lege' is governmental faction
		fSlots = 10, -- slots limit
		fRanks = {
			[1] = {rank = "Asistent", salary = 800001},
			[2] = {rank = "Paramedic", salary = 950001},
			[3] = {rank = "Medic", salary = 1000001},
			[4] = {rank = "Sef Spital", salary = 1200001},
			[5] = {rank = "Director", salary = 1400001}
		}
	},
---Police---
   ["Politia Romana"] = {
	fType = "Lege",
	fSlots = 10,
	fRanks = {
		[1] = {rank = "Cadet", salary = 650001},
		[2] = {rank = "Agent", salary = 700001},
		[3] = {rank = "Agent Principal", salary = 850001},
		[4] = {rank = "Inspector", salary = 950001},
		[5] = {rank = "Comisar", salary = 1200001},
		[6] = {rank = "Chestor", salary = 1500001},
		[7] = {rank = "Chestor General", salary = 1700001}
	}
},
--SWAT
	["S.I.A.S"] = {
		fSlots = 10,
		fType = "Lege",
		fRanks = {
			[1] = {rank = "Agent", salary = 10000000},
			[2] = {rank = "Agent Special", salary = 1200000},
			[3] = {rank = "Agent de Elita ", salary = 1400000},
			[4] = {rank = "Sef", salary = 1600000},
			[5] = {rank = "Director ", salary = 1800000},
			[6] = {rank = "Director Executiv", salary = 2000000}
		}
	},
	--FBI
	["FBI"] = {
		fSlots = 10,
		fType = "Lege",
		fRanks = {
		    [1] = {rank = "FBI Special Agent", salary = 35001},
			[2] = {rank = "FBI Professional Agent", salary = 45001},
			[3] = {rank = "FBI Supervisor", salary = 60001},
			[4] = {rank = "FBI Supervisor+", salary = 90001},
			[5] = {rank = "FBI Tester", salary = 120001},
			[6] = {rank = "Director Departament FBI", salary = 150001},
		}
	},


	--Mafia Faction--
	["Crips"] = {
		fSlots = 7, --Limit Slots 
		fType = "Mafie", -- 'Mafie' is type of Mafia Faction
		fRanks = {
		    [1] = {rank = "Rank 1", salary = 10001},
			[2] = {rank = "Rank 2", salary = 20001},
			[3] = {rank = "Rank 3", salary = 35001},
			[4] = {rank = "Rank 4", salary = 45001}
		}
	},

	-- to add more mafia copy and paste this line and change this name

}

return cfg