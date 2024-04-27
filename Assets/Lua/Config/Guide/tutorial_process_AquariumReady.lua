--[[ 
 * Descripttion: 
 * version: 
 * Author: Bryant
 * Date: 2020-10-09 17:51:51
 * LastEditors: Bryant
 * LastEditTime: 2020-10-09 17:52:51
 ]]

local endFunc = {
	[1] = function (funcID, opened)
		return opened and funcID == GameSystemType.FID_AQUARIUM
	end,
}

tutorial_process_AquariumReady =
{
	-- 对话
	[1] = {stepId=1,mask = true, eventBegin="", delayTime=0, eventEnd=Event.OPEN_FUNC, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=8, tipType="story"}, 
		}
	},
	[2] = {stepId=2,mask = true, eventBegin="", delayTime=0, eventEnd=Event.OPEN_FUNC, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=22, tipType="story"}, 
		}
	},
	--页签点击
	[3] = {stepId=3,mask = false, eventBegin="", delayTime=0, eventEnd=Event.OPEN_FUNC, beginFuc="", endFunc=endFunc[1], 
		['tips'] = {
			[1] = {param01=UIKey.AquariumTabBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
}