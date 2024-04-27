--[[ 
 * Descripttion: 
 * version: 
 * Author: Mingo
 * Date: 2020-04-08 17:25:59
 * LastEditors: Mingo
 * LastEditTime: 2020-06-12 15:19:00
 ]]
_G['GuideFirstEquipConfig']=
{
	-- 剧情5
	[1] = {stepId=1,mask = false,eventBegin="", delayTime=3, eventEnd=nil, beginFuc="", endFunc="",compeletCheck = true,
		['tips'] = {
			[1] = {param04=nil, param05=5, param01=nil, param02="", param03=nil, tipType="story"}, 
		}
	}, 
	--打开角色页面
	[2] = {stepId=2,mask = false,eventBegin="", delayTime=0, eventEnd=Event.YD_OPEN_ACTOR_PAGE, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param04=nil, param05=nil, param01=UIKey.EnterActorBtn, param02="", param03=nil, tipType="click"}, 
		}
	}, 
	--选择装备
	[3] = {stepId=3,mask = true, eventBegin="", delayTime=1, eventEnd=Event.Open_EEUIP_Page, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param04=nil, param05=nil, param01=UIKey.NewEquipItem, param02="", param03=nil, tipType="click"}, 
		}
	}, 
	--选择第一件装备
	[4] = {stepId=4,mask = true, eventBegin="", delayTime=1, eventEnd=Event.PLAYER_SELECT_EQUIP, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param04=nil, param05=nil, param01=UIKey.EquipPackList, param02=1, param03=nil, tipType="click"}, 
		}
	}, 
	--点击替换button
	[5] = {stepId=5,mask = true, eventBegin="", delayTime=0, eventEnd=Event.UPDATE_ACTOR_EQUIPS, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param04=nil, param05=nil, param01=UIKey.ReplaceEquip, param02="", param03=nil, tipType="click"}, 
		}
	}, 
	--回到战斗界面
	[6] = {stepId=6,mask = true, eventBegin="", delayTime=0, eventEnd=Event.YD_OPEN_BATTLE_PAGE, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param04=nil, param05=nil, param01=UIKey.EnterBattleBtn, param02="", param03=nil, tipType="click"}, 
		}
	}, 
	--剧情6
	[7] = {stepId=7,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param04=nil, param05=6, param01=nil, param02="", param03=nil, tipType="story"}, 
		}
	}, 
	--释放技能
	--[8] = {stepId=8,mask = false, eventBegin="", delayTime=1, eventEnd=Event.BATTLE_SKILL_RELEASE, beginFuc="", endFunc="", 
	--	['tips'] = {
	--		[1] = {param04=nil, param05=nil, param01=UIKey.EquipSkillBtn, param02="", param03=nil, tipType="click"}, 
	--	}
	--},

}