--[[ 
 * Descripttion: 
 * version: 
 * Author: Bryant
 * Date: 2020-10-09 17:51:51
 * LastEditors: Bryant
 * LastEditTime: 2020-10-09 17:52:51
 ]]

tutorial_process_TitleReady =
{
	-- 对话
	[1] = {stepId=1,mask = true, eventBegin="", delayTime=0, eventEnd=Event.OPEN_FUNC, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=nil, param02="", param03=nil, param04=nil, param05=11, tipType="story"}, 
		}
	},
	--页签点击
	[2] = {stepId=2,mask = false, eventBegin="", delayTime=0, eventEnd=Event.OPEN_FUNC, beginFuc="", endFunc="", 
		['tips'] = {
			[1] = {param01=UIKey.AchievementTabBtn, param02="", param03=nil, param04=nil, param05=nil, tipType="click"}, 
		}
	},
}