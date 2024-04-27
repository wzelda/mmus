--[[ 
 * Descripttion: 引导的主配置类
 * version: 
 * Author: Mingo
 * Date: 2020-04-07 17:13:04
 * LastEditors: Mingo
 * LastEditTime: 2020-06-06 18:00:39
 ]]

local InUIType = {
	Aqua = {UIInfo.MainUI,1},
	NotAqua = {UIInfo.MainUI,-1},
	NotImprove = {UIInfo.MainUI,-2},
	Fishing = {UIInfo.MainUI,3},
	NotTitle = {UIInfo.MainUI,-5},
	FishFight = {UIInfo.FishFightUI},
}

_G['GuideCfgTable']=
{
	{guideId=5, guideName="黑屏文字", catName="tutorial_process_Welcome", fileName="", desc="黑屏文字", order=1, eventFinished="", condition="", delay=0, startEvo="", 
		['trigger'] = {
			{tipType=Event.CG_ENTER_MAINUI, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=10, guideName="首次进游戏", catName="tutorial_process_FirstGame", fileName="", desc="首次进游戏", order=1, eventFinished="", condition="", delay=0, startEvo="", 
		['trigger'] = {
			{tipType=Event.CG_ENTER_MAINUI, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=20, guideName="挑战第一条鱼", catName="tutorial_process_FirstFish", fileName="", desc="挑战第一条鱼", order=1, eventFinished="", condition="InUI", delay=0, startEvo=InUIType.Fishing, 
		['trigger'] = {
			{tipType=Event.CG_ENTER_MAINUI, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=30, guideName="钓鱼暴击", catName="tutorial_process_ChallengeFish", fileName="", desc="钓鱼暴击", order=1, eventFinished="", condition="", delay=0, startEvo=InUIType.FishFight, 
		['trigger'] = {
			{tipType=Event.CG_CANCRIT},
		}, cantSkip=false
	},
	{guideId=40, guideName="升级第一条鱼", catName="tutorial_process_LevelupFish", fileName="", desc="升级第一条鱼", order=1, eventFinished="", condition=1, delay=0, startEvo=InUIType.Fishing, 
		['trigger'] = {
			{tipType=Event.OPEN_FUNC, param01=GameSystemType.FID_FISHING, param02=true, param03=""}, 	
			{tipType=Event.CLOSED_UI, param01=nil, param02=nil, param03=""},
			{tipType=Event.CLOSED_TAB, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=45, guideName="领取首个任务奖励", catName="tutorial_process_GrabMaintask", fileName="", desc="领取首个任务奖励", order=1, eventFinished="", condition=45, delay=0, startEvo=InUIType.Fishing, 
		['trigger'] = {
			{tipType=Event.CURRENCY_CHANGED, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=47, guideName="观赏馆可解锁", catName="tutorial_process_AquariumReady", fileName="", desc="观赏馆可解锁", order=1, eventFinished="", condition=47, delay=0, startEvo=InUIType.NotAqua, 
		['trigger'] = {
			{tipType=Event.CURRENCY_CHANGED, param01=GameSystemType.FID_AQUARIUM, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=49, guideName="观赏馆倍数", catName="tutorial_process_AquarMultiple", fileName="", desc="观赏馆倍数", order=1, eventFinished="", condition=49, delay=0, startEvo=InUIType.Aqua, 
		['trigger'] = {
			{tipType=Event.OPEN_FUNC, param01=GameSystemType.FID_AQUARIUM, param02=true, param03=""},
			{tipType=Event.AQUARIUM_LEVELUP_DECORATION, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=51, guideName="管理可解锁", catName="tutorial_process_ImproveReady", fileName="", desc="管理可解锁", order=1, eventFinished="", condition="", delay=0, startEvo=InUIType.NotImprove, 
		['trigger'] = {
			{tipType=Event.CURRENCY_CHANGED, param01=GameSystemType.FID_IMPROVE, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=52, guideName="成就可解锁", catName="tutorial_process_TitleReady", fileName="", desc="成就可解锁", order=1, eventFinished="", condition="", delay=0, startEvo=InUIType.NotTitle, 
		['trigger'] = {
			{tipType=Event.CURRENCY_CHANGED, param01=GameSystemType.FID_LIBRARY, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=55, guideName="解锁夏威夷主线任务", catName="tutorial_process_UnlockseaMainTask", fileName="", desc="解锁夏威夷主线任务", order=1, eventFinished="", condition=55, delay=0, startEvo=InUIType.NotTitle, 
		['trigger'] = {
			{tipType=Event.CG_ENTER_MAINUI, param01=nil, param02=nil, param03=""},
			{tipType=Event.GET_MAIN_TASK_PRIZE, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=60, guideName="夏威夷海域可解锁", catName="tutorial_process_HawaiiReady", fileName="", desc="夏威夷海域可解锁", order=1, eventFinished="", condition=60, delay=0, startEvo=InUIType.Fishing, 
		['trigger'] = {
			{tipType=Event.CG_ENTER_MAINUI, param01=nil, param02=nil, param03=""},
			{tipType=Event.OPEN_FUNC, param01=GameSystemType.FID_FISHING, param02=true, param03=""},
			{tipType=Event.AQUARIUM_LEVELUP_DECORATION, param01=nil, param02=nil, param03=""},
			{tipType=Event.FISH_LEVELUP, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},
	{guideId=70, guideName="夏威夷观赏馆可解锁", catName="tutorial_process_HallAquarReady", fileName="", desc="夏威夷观赏馆可解锁", order=1, eventFinished="", condition=70, delay=0, startEvo=InUIType.Aqua, 
		['trigger'] = {
			{tipType=Event.CG_ENTER_MAINUI},
			{tipType=Event.OPEN_FUNC}, 	
			{tipType=Event.AQUARIUM_LEVELUP_DECORATION, param01=nil, param02=nil, param03=""},
			{tipType=Event.FISH_LEVELUP, param01=nil, param02=nil, param03=""},
		}, cantSkip=false
	},

	-- 模板
	-- [3] = {guideId=3, guideName="第一件装备", catName="GuideFirstEquipConfig", fileName="GuideFirstEquip", desc="穿装备", order=1, eventFinished="", condition="", delay=0, startEvo="", 
	-- 	['trigger'] = {
	-- 		{tipType=Event.UPDATE_EQUIP_NEW, param01=3010001, param02=nil, param03="GuideFirstEquip:GetNewEquip()"}, 
	-- 	}, cantSkip=false
	-- },
}