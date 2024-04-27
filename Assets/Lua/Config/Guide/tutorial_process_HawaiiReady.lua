local function endEvtFunc(uiname)
	return uiname == UIInfo.EarthUI.UIComName
end

local function endEvtFunc2(uiname)
	return uiname == UIInfo.OceanAeraUI.UIComName
end

 tutorial_process_HawaiiReady =
{
	-- 对话
	[1] = {stepId=1,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=12, tipType="story"}, 
		}
	},
	[2] = {stepId=2,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=13, tipType="story"}, 
		}
	},
	--点击
	[3] = {stepId=3,mask = false, eventBegin="", delayTime=0, eventEnd=Event.OPENED_TAB, beginFuc="", endFunc=endEvtFunc, 
		['tips'] = {
			[1] = {param01=UIKey.EarthBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
	[4] = {stepId=4,mask = false, eventBegin="", delayTime=0, eventEnd=Event.OPENED_UI, beginFuc="", endFunc=endEvtFunc2, 
		['tips'] = {
			[1] = {param01=UIKey.SecondSeaBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
}