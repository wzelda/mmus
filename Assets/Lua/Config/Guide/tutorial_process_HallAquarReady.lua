
tutorial_process_HallAquarReady =
{
	-- 对话
	{stepId=1,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=14, tipType="story"}, 
		}
	},
	-- {stepId=2,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc=nil, 
	-- 	['tips'] = {
	-- 		[1] = {param01=UIKey.AquariumTabBtn, param02=nil, param03=nil, param04=nil, param05=nil, tipType="click"}, 
	-- 	}
	-- },
	{stepId=2,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=15, tipType="story"}, 
		}
	},
	{stepId=3,mask = false, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc=nil, 
		['tips'] = {
			[1] = {param01=UIKey.BuildAquaBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
}