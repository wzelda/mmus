
tutorial_process_GrabMaintask =
{
	[1] = {stepId=1,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=7, tipType="story"}, 
		}
	},
	[2] = {stepId=2,mask = true, eventBegin="", delayTime=0, eventEnd=nil, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=21, tipType="story"}, 
		}
	},
	[3] = {stepId=3,mask = false, eventBegin="", delayTime=0, eventEnd=Event.GET_MAIN_TASK_PRIZE, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=UIKey.MaintaskBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
}