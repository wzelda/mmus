-- Generated by github.com/davyxu/tabtoy
-- Version: 3.0.1

local tab = {
	GuideStory = {
		{ ID = 1, Dialog = "Dialog_10_1", Pos = 1 	},
		{ ID = 2, Dialog = "Dialog_10_2", Pos = 2 	},
		{ ID = 3, Dialog = "Dialog_10_3", Pos = 3 	},
		{ ID = 4, Dialog = "Dialog_20_1", Pos = 1 	},
		{ ID = 5, Dialog = "Dialog_30_1", Pos = 2 	},
		{ ID = 6, Dialog = "Dialog_40_1", Pos = 3 	},
		{ ID = 7, Dialog = "Dialog_45_1", Pos = 1 	},
		{ ID = 8, Dialog = "Dialog_47_1", Pos = 2 	},
		{ ID = 9, Dialog = "Dialog_49_1", Pos = 3 	},
		{ ID = 10, Dialog = "Dialog_51_1", Pos = 1 	},
		{ ID = 11, Dialog = "Dialog_52_1", Pos = 2 	},
		{ ID = 12, Dialog = "Dialog_60_1", Pos = 3 	},
		{ ID = 13, Dialog = "Dialog_60_2", Pos = 1 	},
		{ ID = 14, Dialog = "Dialog_70_1", Pos = 2 	},
		{ ID = 15, Dialog = "Dialog_70_2", Pos = 3 	},
		{ ID = 16, Dialog = "Dialog_5_1", Pos = 0 	},
		{ ID = 17, Dialog = "Dialog_10_4", Pos = 0 	},
		{ ID = 18, Dialog = "Dialog_10_5", Pos = 0 	},
		{ ID = 19, Dialog = "Dialog_20_2", Pos = 0 	},
		{ ID = 20, Dialog = "Dialog_40_2", Pos = 0 	},
		{ ID = 21, Dialog = "Dialog_45_2", Pos = 0 	},
		{ ID = 22, Dialog = "Dialog_47_2", Pos = 0 	},
		{ ID = 23, Dialog = "Dialog_55_1", Pos = 0 	}
	}

}


-- ID
tab.GuideStoryByID = {}
for _, rec in pairs(tab.GuideStory) do
	tab.GuideStoryByID[rec.ID] = rec
end

tab.Enum = {
}

return tab