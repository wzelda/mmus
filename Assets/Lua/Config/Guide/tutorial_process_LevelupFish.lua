local function beginEvt(uiname)
	return uiname == UIInfo.FishFightUI.UIComName
end

tutorial_process_LevelupFish =
{
	-- 对话
	[1] = {stepId=1,mask = true, eventBegin=nil, delayTime=0, eventEnd=nil, beginFuc=nil, endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=6, tipType="story"}, 
		}
	},
	[2] = {stepId=2,mask = true, eventBegin=nil, delayTime=0, eventEnd=nil, beginFuc=nil, endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=20, tipType="story"}, 
		}
	},
	--点击
	[3] = {stepId=3,mask = false, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=UIKey.FistFishBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
	[4] = {stepId=4,mask = false, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=UIKey.FistFishBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
	[5] = {stepId=5,mask = false, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc=nil, 
		['tips'] = {
			[1] = {param01=UIKey.FistFishBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
}