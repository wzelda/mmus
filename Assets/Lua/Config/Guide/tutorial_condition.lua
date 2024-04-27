--[[ 
 * Descripttion: 引导的主配置类
 * version: 
 * Author: Bryant
 * Date: 2020-10-26 17:17:04
 * LastEditors: Bryant
 * LastEditTime: 2020-10-26 18:00:39
 ]]

 local tutorial_condition = {}

 -- 检测所在UI
--  原则：已配置则判断，未配置则通过
 local function inUI(cfg)
	if type(cfg.startEvo) ~= "table" then
		return true
	end
	-- panelinfo
	local uiInfo = cfg.startEvo[1]
	if nil == uiInfo then return true end

	local topUI = UIManager.GetTopOpenUI()
	if topUI.PanelInfo ~= uiInfo then
		return false
	end
	-- panelinfo.UILogic
	local tab = cfg.startEvo[2]
	if nil == tab then return true end

	if uiInfo == UIInfo.MainUI then
		-- 底部页签
		if tab > 0 then
			return topUI.MainBottomUI.tabIndex == tab - 1
		else
			-- 负数表示不在该页签
			return topUI.MainBottomUI.tabIndex ~= -tab - 1
		end
	else
		return topUI.curTab == topUI.Tabs[tab]
	end
 end

 tutorial_condition.InUI = inUI

 tutorial_condition[1] = function (cfg)
	local fishId = ConfigData.fishConfig.Fishes[1].ID
	return PlayerDatas.FishData:OwnedFish(fishId, 1) and not PlayerDatas.FishData:OwnedFish(fishId, 4)
 end

tutorial_condition[45] = function (cfg)
	local taskId = ConfigData.mainTaskConfig.MainTask[1].ID
	return PlayerDatas.TaskData:IsMainTaskComplete(taskId)
end

tutorial_condition[49] = function (cfg)
	local aquar = PlayerDatas.AquariumData.TheConfig.Aquariums[1]
	local firstId = aquar and aquar.ShowItems[1]
	if firstId then
		return PlayerDatas.DecorationData:OwnedDecoration(firstId, 2)
	end

	return false
end

 tutorial_condition[47] = function ()
	local conOpen = PlayerDatas.FunctionOpenData:ReadyUnlockById(GameSystemType.FID_AQUARIUM)
	local conClose = PlayerDatas.FunctionOpenData:IsFunctionOpened(GameSystemType.FID_AQUARIUM)

	return conOpen, conClose
 end

 tutorial_condition[55] = function ()
	local task = PlayerDatas.TaskData:GetCurMainTask()
	return nil ~= task and task.ID == 17
 end

 tutorial_condition[60] = function ()
	-- 可解锁第二个海域
	local cfg = ConfigData.seaConfig.Seas[2]
	if cfg and not PlayerDatas.SeaData:SeaUnlocked(cfg.ID) 
	and DependManager.PassedDepend(cfg.Depends)
	then
		return true
	end

	return false
 end

tutorial_condition[70] = function (cfg)
	local aquar = PlayerDatas.AquariumData.TheConfig.Aquariums[2]
	if aquar and PlayerDatas.AquariumData.aquariums[aquar.ID] == nil then
		if DependManager.PassedDepend(aquar.Depends) then
			return true
		end
	end
	return false
end

return tutorial_condition