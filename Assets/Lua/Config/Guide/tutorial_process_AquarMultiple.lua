
tutorial_process_AquarMultiple =
{
	-- 对话
	[1] = {stepId=1,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=9, tipType="story"}, 
		}
	},
	--点击
	[2] = {stepId=2,mask = true, eventBegin="", delayTime=0, eventEnd=Event.BATCH_COUNT_CHANGE, beginFuc="", endFunc=nil, 
		['tips'] = {
			[1] = {param01=UIKey.MultiSpeedBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
}