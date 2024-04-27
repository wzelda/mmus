-- Generated by github.com/davyxu/tabtoy
-- Version: 3.0.1

local tab = {
	OfflineReward = {
		{ ID = 1, Offtime = 2, Duration = 30, Coef = 1, RewardType = { 1 }, Adadd = 2 	}
	}, 

	BoxConfig = {
		{ Key = "AdBoxCds", Cd = 120, Rate = 300, Number = 10 	}
	}, 

	PeriodReward = {
		{ ID = 1, RewardDur = 10, Diamond = 20 	}
	}, 

	DoubleReward = {
		{ ID = 1, Duration = 360, MaxDur = 540, Buffer = 1, Desc = "Use ad, you will get\n\n[color=#ffd247][size=86]6 hours[/size][/color] revenuce doubles!" 	}
	}, 

	ShipTreasure = {
		{ ID = 1, Name = "Bow", CostType = 2, Cost = 10, RewardDur = 3, FreeTimes = 20, CdFree = 0, Cd = 100 	},
		{ ID = 2, Name = "Deck", CostType = 2, Cost = 60, RewardDur = 18, FreeTimes = 0, CdFree = 0, Cd = 0 	},
		{ ID = 3, Name = "Cabin", CostType = 2, Cost = 300, RewardDur = 96, FreeTimes = 0, CdFree = 0, Cd = 0 	}
	}, 

	FishShip = {
		{ Key = "ShipFishingCd", Desc = "Pelagic fishing Cd", Number = 10800 	},
		{ Key = "ShipFishingRewardRate", Desc = "Pelagic fishing reward cooldown", Number = 1200 	},
		{ Key = "ShipFishingCost", Desc = "Consume diamonds to return Pelagic fishing", Number = 50 	}
	}

}


-- ID
tab.OfflineRewardByID = {}
for _, rec in pairs(tab.OfflineReward) do
	tab.OfflineRewardByID[rec.ID] = rec
end

-- Key
tab.BoxConfigByKey = {}
for _, rec in pairs(tab.BoxConfig) do
	tab.BoxConfigByKey[rec.Key] = rec
end

-- ID
tab.PeriodRewardByID = {}
for _, rec in pairs(tab.PeriodReward) do
	tab.PeriodRewardByID[rec.ID] = rec
end

-- ID
tab.DoubleRewardByID = {}
for _, rec in pairs(tab.DoubleReward) do
	tab.DoubleRewardByID[rec.ID] = rec
end

-- ID
tab.ShipTreasureByID = {}
for _, rec in pairs(tab.ShipTreasure) do
	tab.ShipTreasureByID[rec.ID] = rec
end

-- Key
tab.FishShipByKey = {}
for _, rec in pairs(tab.FishShip) do
	tab.FishShipByKey[rec.Key] = rec
end

tab.Enum = {
}

return tab