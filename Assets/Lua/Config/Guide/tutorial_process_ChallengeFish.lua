
tutorial_process_ChallengeFish =
{
	-- {stepId=1,mask = true, pause = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
	-- 	['tips'] = {
	-- 		[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=5, tipType="story"}, 
	-- 	}
	-- },
	{stepId=2,mask = true, pause = true, eventBegin="", delayTime=0, eventEnd=Event.CG_CRIT_SUCCESS, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=UIKey.FishCtrlBtn, param02="", param03=Vector2(0,-566), param04=nil, param05=nil, tipType="click", hideFinger = true}, 
		}
	},
}