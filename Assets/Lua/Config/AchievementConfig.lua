-- Generated by github.com/davyxu/tabtoy
-- Version: 3.0.1

local tab = {
	AchievementTitle = {
		{ ID = 1, Name = "钓鱼菜鸟", Icon = "chengjiu1", Condition = 0, RewardType = 2, Reward = 20 	},
		{ ID = 2, Name = "钓鱼好手", Icon = "chengjiu2", Condition = 10, RewardType = 2, Reward = 50 	},
		{ ID = 3, Name = "钓鱼高手I", Icon = "chengjiu3", Condition = 18, RewardType = 2, Reward = 60 	},
		{ ID = 4, Name = "钓鱼高手II", Icon = "chengjiu3", Condition = 30, RewardType = 2, Reward = 70 	},
		{ ID = 5, Name = "钓鱼高手III", Icon = "chengjiu3", Condition = 40, RewardType = 2, Reward = 80 	},
		{ ID = 6, Name = "钓鱼大师I", Icon = "chengjiu4", Condition = 50, RewardType = 2, Reward = 90 	},
		{ ID = 7, Name = "钓鱼大师II", Icon = "chengjiu4", Condition = 60, RewardType = 2, Reward = 100 	},
		{ ID = 8, Name = "钓鱼大师III", Icon = "chengjiu4", Condition = 75, RewardType = 2, Reward = 110 	},
		{ ID = 9, Name = "钓鱼大亨", Icon = "chengjiu5", Condition = 90, RewardType = 2, Reward = 120 	}
	}, 

	AchievementTask = {
		{ ID = 100001, Name = "累积解锁1条鱼", TaskId = 100001, Prev = 0, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 100002, Name = "累积解锁3条鱼", TaskId = 100002, Prev = 100001, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 100003, Name = "累积解锁6条鱼", TaskId = 100003, Prev = 100002, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 100004, Name = "累积解锁10条鱼", TaskId = 100004, Prev = 100003, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 100005, Name = "累积解锁15条鱼", TaskId = 100005, Prev = 100004, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 100006, Name = "累积解锁20条鱼", TaskId = 100006, Prev = 100005, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 100007, Name = "累积解锁25条鱼", TaskId = 100007, Prev = 100006, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 200001, Name = "累积进修1次", TaskId = 200001, Prev = 0, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200002, Name = "累积进修5次", TaskId = 200002, Prev = 200001, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200003, Name = "累积进修15次", TaskId = 200003, Prev = 200002, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200004, Name = "累积进修30次", TaskId = 200004, Prev = 200003, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200005, Name = "累积进修50次", TaskId = 200005, Prev = 200004, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200006, Name = "累积进修70次", TaskId = 200006, Prev = 200005, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200007, Name = "累积进修100次", TaskId = 200007, Prev = 200006, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200008, Name = "累积进修150次", TaskId = 200008, Prev = 200007, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200009, Name = "累积进修200次", TaskId = 200009, Prev = 200008, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200010, Name = "累积进修250次", TaskId = 200010, Prev = 200009, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200011, Name = "累积进修300次", TaskId = 200011, Prev = 200010, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 200012, Name = "累积进修360次", TaskId = 200012, Prev = 200011, RewardType = 2, Reward = 5, Ad = 0 	},
		{ ID = 300001, Name = "累积解锁1个装饰物", TaskId = 300001, Prev = 0, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 300002, Name = "累积解锁5个装饰物", TaskId = 300002, Prev = 300001, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 300003, Name = "累积解锁10个装饰物", TaskId = 300003, Prev = 300002, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 300004, Name = "累积解锁15个装饰物", TaskId = 300004, Prev = 300003, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 300005, Name = "累积解锁20个装饰物", TaskId = 300005, Prev = 300004, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 300006, Name = "累积解锁25个装饰物", TaskId = 300006, Prev = 300005, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 300007, Name = "累积解锁30个装饰物", TaskId = 300007, Prev = 300006, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 300008, Name = "累积解锁35个装饰物", TaskId = 300008, Prev = 300007, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 300009, Name = "累积解锁40个装饰物", TaskId = 300009, Prev = 300008, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 300010, Name = "累积解锁45个装饰物", TaskId = 300010, Prev = 300009, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 400001, Name = "鱼累积成长1次", TaskId = 400001, Prev = 0, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400002, Name = "鱼累积成长5次", TaskId = 400002, Prev = 400001, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400003, Name = "鱼累积成长10次", TaskId = 400003, Prev = 400002, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400004, Name = "鱼累积成长15次", TaskId = 400004, Prev = 400003, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400005, Name = "鱼累积成长20次", TaskId = 400005, Prev = 400004, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400006, Name = "鱼累积成长25次", TaskId = 400006, Prev = 400005, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400007, Name = "鱼累积成长30次", TaskId = 400007, Prev = 400006, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400008, Name = "鱼累积成长35次", TaskId = 400008, Prev = 400007, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400009, Name = "鱼累积成长40次", TaskId = 400009, Prev = 400008, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400010, Name = "鱼累积成长45次", TaskId = 400010, Prev = 400009, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 400011, Name = "鱼累积成长50次", TaskId = 400011, Prev = 400010, RewardType = 2, Reward = 10, Ad = 0 	},
		{ ID = 500001, Name = "解锁第2个钓鱼海域", TaskId = 500001, Prev = 0, RewardType = 2, Reward = 35, Ad = 1 	},
		{ ID = 500002, Name = "解锁第3个钓鱼海域", TaskId = 500002, Prev = 500001, RewardType = 2, Reward = 35, Ad = 1 	},
		{ ID = 600001, Name = "累积打开1个漂流宝箱", TaskId = 600001, Prev = 0, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600002, Name = "累积打开5个漂流宝箱", TaskId = 600002, Prev = 600001, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600003, Name = "累积打开10个漂流宝箱", TaskId = 600003, Prev = 600002, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600004, Name = "累积打开15个漂流宝箱", TaskId = 600004, Prev = 600003, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600005, Name = "累积打开20个漂流宝箱", TaskId = 600005, Prev = 600004, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600006, Name = "累积打开28个漂流宝箱", TaskId = 600006, Prev = 600005, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600007, Name = "累积打开36个漂流宝箱", TaskId = 600007, Prev = 600006, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600008, Name = "累积打开44个漂流宝箱", TaskId = 600008, Prev = 600007, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600009, Name = "累积打开52个漂流宝箱", TaskId = 600009, Prev = 600008, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600010, Name = "累积打开60个漂流宝箱", TaskId = 600010, Prev = 600009, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600011, Name = "累积打开68个漂流宝箱", TaskId = 600011, Prev = 600010, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600012, Name = "累积打开76个漂流宝箱", TaskId = 600012, Prev = 600011, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600013, Name = "累积打开84个漂流宝箱", TaskId = 600013, Prev = 600012, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600014, Name = "累积打开92个漂流宝箱", TaskId = 600014, Prev = 600013, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600015, Name = "累积打开100个漂流宝箱", TaskId = 600015, Prev = 600014, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600016, Name = "累积打开110个漂流宝箱", TaskId = 600016, Prev = 600015, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600017, Name = "累积打开120个漂流宝箱", TaskId = 600017, Prev = 600016, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600018, Name = "累积打开130个漂流宝箱", TaskId = 600018, Prev = 600017, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600019, Name = "累积打开140个漂流宝箱", TaskId = 600019, Prev = 600018, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600020, Name = "累积打开150个漂流宝箱", TaskId = 600020, Prev = 600019, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600021, Name = "累积打开170个漂流宝箱", TaskId = 600021, Prev = 600020, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 600022, Name = "累积打开190个漂流宝箱", TaskId = 600022, Prev = 600021, RewardType = 2, Reward = 20, Ad = 0 	},
		{ ID = 600023, Name = "累积打开210个漂流宝箱", TaskId = 600023, Prev = 600022, RewardType = 2, Reward = 20, Ad = 1 	},
		{ ID = 700001, Name = "累积观看广告1次", TaskId = 700001, Prev = 0, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 700002, Name = "累积观看广告5次", TaskId = 700002, Prev = 700001, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 700003, Name = "累积观看广告10次", TaskId = 700003, Prev = 700002, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700004, Name = "累积观看广告15次", TaskId = 700004, Prev = 700003, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 700005, Name = "累积观看广告20次", TaskId = 700005, Prev = 700004, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700006, Name = "累积观看广告25次", TaskId = 700006, Prev = 700005, RewardType = 2, Reward = 15, Ad = 0 	},
		{ ID = 700007, Name = "累积观看广告30次", TaskId = 700007, Prev = 700006, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700008, Name = "累积观看广告40次", TaskId = 700008, Prev = 700007, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700009, Name = "累积观看广告50次", TaskId = 700009, Prev = 700008, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700010, Name = "累积观看广告60次", TaskId = 700010, Prev = 700009, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700011, Name = "累积观看广告70次", TaskId = 700011, Prev = 700010, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700012, Name = "累积观看广告80次", TaskId = 700012, Prev = 700011, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700013, Name = "累积观看广告90次", TaskId = 700013, Prev = 700012, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700014, Name = "累积观看广告100次", TaskId = 700014, Prev = 700013, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700015, Name = "累积观看广告150次", TaskId = 700015, Prev = 700014, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700016, Name = "累积观看广告200次", TaskId = 700016, Prev = 700015, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700017, Name = "累积观看广告250次", TaskId = 700017, Prev = 700016, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700018, Name = "累积观看广告300次", TaskId = 700018, Prev = 700017, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700019, Name = "累积观看广告400次", TaskId = 700019, Prev = 700018, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700020, Name = "累积观看广告500次", TaskId = 700020, Prev = 700019, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700021, Name = "累积观看广告600次", TaskId = 700021, Prev = 700020, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700022, Name = "累积观看广告700次", TaskId = 700022, Prev = 700021, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700023, Name = "累积观看广告800次", TaskId = 700023, Prev = 700022, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700024, Name = "累积观看广告900次", TaskId = 700024, Prev = 700023, RewardType = 2, Reward = 15, Ad = 1 	},
		{ ID = 700025, Name = "累积观看广告1000次", TaskId = 700025, Prev = 700024, RewardType = 2, Reward = 15, Ad = 1 	}
	}

}


-- ID
tab.AchievementTitleByID = {}
for _, rec in pairs(tab.AchievementTitle) do
	tab.AchievementTitleByID[rec.ID] = rec
end

-- ID
tab.AchievementTaskByID = {}
for _, rec in pairs(tab.AchievementTask) do
	tab.AchievementTaskByID[rec.ID] = rec
end

tab.Enum = {
}

return tab