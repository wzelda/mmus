local PlayerInfomationPanel = UIManager.PanelFactory(UIInfo.PlayerInfomationUI)

local panel = nil

PlayerInfomationPanel.HidePrePanel = true
PlayerInfomationPanel.ShowAvatarTool = nil
PlayerInfomationPanel.userViewInfo = nil
PlayerInfomationPanel.tabEquipsCom = nil
PlayerInfomationPanel.tabSlotStar_C = nil
PlayerInfomationPanel.tabEquipInfo = nil
PlayerInfomationPanel.tabSlotData = nil

local function OnClosePanel()
    UIManager.CloseUI(UIInfo.PlayerInfomationUI)
end

-- 打开装备详情
local function OpenEquipDetails(index)
    if index < 8 then
        panel.state_C.selectedIndex = 1

        CommonUIUtils.FillEquipInfo(panel.equipDetails, panel.tabEquipInfo[index], nil, true, panel.tabSlotData[index], panel.tabSlotData)
    end
end

local function CloseEquipDetails()
    panel.state_C.selectedIndex = 0
end

-- 填充装备列表
function PlayerInfomationPanel:FillEquipList()
    local equipIndex = 1
    for _, slotData in ipairs(self.userViewInfo.actor.equip_slot_list) do
        local equipProto = slotData.equip
        local equip = PlayerData.Datas.EquipData:Clone({
            id = equipProto.id,
            data_id = equipProto.data_id,
            stat = equipProto.stat,
            viewed = true,
            base_stat = equipProto.base_stat,
            equipData = ConfigData:GetEquipDataById(equipProto.data_id),
            gem_list = equipProto.gem_list,
            locked = equipProto.locked,
            random_stat = equipProto.random_stat,
            skill_id = equipProto.skill_id,
        })

        if equip.equipData.part_type == EquipPartType.WU_QI then
            equipIndex = 1
        elseif equip.equipData.part_type == EquipPartType.TOU_KUI then
            equipIndex = 5
        elseif equip.equipData.part_type == EquipPartType.YI_FU then
            equipIndex = 2
        elseif equip.equipData.part_type == EquipPartType.KU_ZI then
            equipIndex = 6
        elseif equip.equipData.part_type == EquipPartType.XIE_ZI then
            equipIndex = 7
        elseif equip.equipData.part_type == EquipPartType.SHOU_TAO then
            equipIndex = 3
        elseif equip.equipData.part_type == EquipPartType.SHI_PIN then
            equipIndex = 4
        end

        self.tabEquipInfo[equipIndex] = equip
        slotData.star = ConfigData:GetEquipSlotStarDataById(slotData.star_data_id).star
        slotData.equip = equip
        self.tabSlotData[equipIndex] = slotData
        self.tabSlotStar_C[equipIndex].selectedIndex = slotData.star
        CommonUIUtils.SetNewEquipItem(self.tabEquipsCom[equipIndex], equip)
    end
end

-- 填充玩家基础信息
function PlayerInfomationPanel:FillPlayerBasicInfo()
    self.playerName.text = self.userViewInfo.view_basic.basic.name
    self.playerLv.text = "Lv." .. self.userViewInfo.view_basic.basic.level
    self.playerPower.text = Utils.GetCountFormat(self.userViewInfo.actor.fight_amount)
end

-- 创建角色模型
function PlayerInfomationPanel:CreateActorAvatar()
    if self.ShowAvatarTool.avatar then
        self.ShowAvatarTool:ReplacePart()
    else
        local parts = {}
        local userData = PlayerData.Datas.UserData
        local equipData = nil
        for _, slotData in pairs(self.userViewInfo.actor.equip_slot_list) do
            equipData = ConfigData:GetEquipDataById(slotData.equip.data_id)
            parts[equipData.part_type] = equipData.model
        end
        self.ShowAvatarTool:LoadAvatar(ConfigData:FindActorById(self.userViewInfo.actor.data_id).model, parts,
        function()
            self.ShowAvatarTool.avatar.trans.localScale = ConstantValue.V3One * 0.9
        end)
    end
end

-- 初始化玩家信息
function PlayerInfomationPanel:InitPlayerInof()
    self:FillEquipList()
    self:FillPlayerBasicInfo()
    self:CreateActorAvatar()
end

-- 子类初始化UI控件
-- userViewInfo:UserViewProto
function PlayerInfomationPanel:OnOpen(userViewInfo)
    panel = self
    self.userViewInfo = userViewInfo

    self.main = self.UI:GetChild("main")
    self.closeBtn = self.main:GetChild("closeBtn")
    self.playerInfo = self.main:GetChild("playerInfo")
    self.playerName = self.playerInfo:GetChild("playerName")
    self.playerLv = self.playerInfo:GetChild("playerLv")
    self.playerPower = self.playerInfo:GetChild("playerPower")
    self.equipList1 = self.main:GetChild("equipList1")
    self.equipList2 = self.main:GetChild("equipList2")
    self.equipDetailsCom = self.main:GetChild("equipInfo")
    self.equipDetails = self.equipDetailsCom:GetChild("equipDetails")
    self.closeBg = self.equipDetailsCom:GetChild("closeBg")
    self.actorHolder = self.main:GetChild("actorHolder")
    self.state_C = self.main:GetController("state_C")

    self.tabEquipInfo = {}
    self.tabEquipsCom = {}
    self.tabSlotStar_C = {}
    self.tabSlotData = {}
    for i = 1, 4 do
        local item = self.equipList1:GetChildAt(i - 1)
        local equipItem = item:GetChild("item")
        local slotStar = item:GetChild("slotStar"):GetController("c1")

        table.insert(self.tabEquipsCom, equipItem)
        table.insert(self.tabSlotStar_C, slotStar)
        item.onClick:Set(
            function()
                OpenEquipDetails(i)
            end
        )
    end

    for i = 1, 4 do
        local item = self.equipList2:GetChildAt(i - 1)
        local equipItem = item:GetChild("item")
        local slotStar = item:GetChild("slotStar"):GetController("c1")

        table.insert(self.tabEquipsCom, equipItem)
        table.insert(self.tabSlotStar_C, slotStar)
        item.onClick:Set(
            function()
                OpenEquipDetails(i + 4)
            end
        )
    end

    if (not self.ShowAvatarTool) then
        local avatarPos = Vector3(4000, 4000, 4000)
        self.ShowAvatarTool = ClassConfig:ShowAvatarToolClass().new(self, self.actorHolder, self.main:GetChild("actorRotateGraph"), nil, avatarPos, true)
    end
end

function PlayerInfomationPanel:OnShow()
    self.state_C.selectedIndex = 0
    self:InitPlayerInof()
    if self.ShowAvatarTool then
        self.ShowAvatarTool:Show()
    end
    BattleManager:HiddenBattle()
end

-- 刷新文本
function PlayerInfomationPanel:RefreshText()

end

-- 绑定各类事件
function PlayerInfomationPanel:OnRegister()
    self.closeBtn.onClick:Add(OnClosePanel)
    self.closeBg.onClick:Add(CloseEquipDetails)
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function PlayerInfomationPanel:OnRefresh(...)
    self:RefreshText()
end

-- 解绑各类事件
function PlayerInfomationPanel:OnUnRegister()
    self.closeBtn.onClick:Clear()
    self.closeBg.onClick:Clear()
end

-- 关闭
function PlayerInfomationPanel:OnClose()
    panel = nil
    self.userViewInfo = nil
    self.tabEquipsCom = nil
    self.tabSlotStar_C = nil
    self.tabSlotData = nil
    if (self.ShowAvatarTool) then
        self.ShowAvatarTool:Destroy()
    end
    self.ShowAvatarTool = nil
    BattleManager:ShowBattle()
end

return PlayerInfomationPanel
--endregion