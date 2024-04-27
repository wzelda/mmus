-- 弹框的打开关闭动画
local PopupAnimTool = {}

-- AnimType 0:无效果， 1：缩放， 2：透明, 3:方法事件
--打开动画参数
PopupAnimTool.OpenAnimParam = {
    --透明度变为在0.2s变为1
    {
        AnimType = 2,
        StartTime = 0,
        EndTime = 0.2,
        StartValue = 0,
        EndValue = 1
    },
    -- 缩放0.06s放大到1.05倍
    {
        AnimType = 1,
        StartTime = 0,
        EndTime = 0.06,
        StartValue = ConstantValue.V2One,
        EndValue = ConstantValue.V2One * 1.05
    },
    -- 缩放0.06s变为1
    {
        AnimType = 1,
        StartTime = 0.06,
        EndTime = 0.12,
        StartValue = ConstantValue.V2One * 1.05,
        EndValue = ConstantValue.V2One
    },
}
PopupAnimTool.CloseAimParam = {
    --透明度变为在0.2s变为0
    {
        AnimType = 2,
        StartTime = 0,
        EndTime = 0.2,
        StartValue = 1,
        EndValue = 0
    },
    --GoWrapper 在1/3的时间内先隐藏
    {
        AnimType = 3,
        StartTime = 0.1,
        EndTime = 0.1,
        HasExe = false,
        EventFunc = nil
    },
    -- 缩放0.06s放大到1.05倍
    {
        AnimType = 1,
        StartTime = 0,
        EndTime = 0.12,
        StartValue = ConstantValue.V2One,
        EndValue = ConstantValue.V2One * 1.05
    },
    -- 缩放0.06s变为1
    {
        AnimType = 1,
        StartTime = 0.12,
        EndTime = 0.06,
        StartValue = ConstantValue.V2One * 1.05,
        EndValue = ConstantValue.V2One * 1.03
    },
}
    
--打开弹框通用动画()
function PopupAnimTool:ShowPopupUIAnim(popupUI, isPanel, panelInfo, completeCb)
    local animItem = nil
    if(not Utils.uITargetIsNil(popupUI))then
        popupUI.pivot = Vector2.one * 0.5
        popupUI.visible = true
        --popupUI:Center()
        local bg = popupUI:GetChild("bg")
        if(bg)then
            bg.alpha = 0.7
            bg.pivot = Vector2.one * 0.5
            bg.scale = Vector2.one * 10
        else
            --UnityEngine.Debug.LogError("弹框没有加bg背景")
        end
        animItem = ClassConfig.PopupAnimItemClass().new()
        local function callBack()
            if type(completeCb) == "function" then
                completeCb()
            end

            EventDispatcher:Dispatch(Event.POPUP_ANIMATION_COMPLETE)
        end
        EventDispatcher:Dispatch(Event.POPUP_ANIMATION_START)
        animItem:Play(popupUI, self.OpenAnimParam, callBack)
    end
    return animItem
end
--关闭弹框通用动画(如果panel,在动画完成之后关闭)
function PopupAnimTool:ClosePopupUIAnim(popupUI, isPanel, panelInfo, needTweenerTimer)
    local animItem = nil
    if(not Utils.uITargetIsNil(popupUI))then     
        local bg = popupUI:GetChild("bg")
        if(bg)then
            bg.pivot = Vector2.one * 0.5
            bg.scale = Vector2.one * 10
        end
        --
        local tabWrap = {}
        local completeFunc = function()
            if(not Utils.uITargetIsNil(popupUI))then 
                if(bg)then
                    bg.scale = Vector2.one
                end
                popupUI.alpha = 1
                --恢复组件初始状态
                self:ResetPopupCom(tabWrap)
                tabWrap = nil
                if(isPanel)then
                    UIManager.CloseUI(panelInfo)
                else
                    popupUI.visible = false 
                end
            end
        end
        animItem = ClassConfig.PopupAnimItemClass().new()
        -- 关闭动画中GoWrapper 在1/3的时间内先隐藏
        self:GetPopupUISpecial(popupUI, tabWrap)
        PopupAnimTool.CloseAimParam[2].EventFunc = function() self:SetPopupCom(tabWrap) end
        PopupAnimTool.CloseAimParam[2].HasExe =false
        animItem:Play(popupUI, self.CloseAimParam, completeFunc)
    end
    return animItem
end

--记录并设置组件里面的投影字体和UI特效，
function PopupAnimTool:GetPopupUISpecial(popupUI, tabWrap)
    if(popupUI and popupUI.numChildren > 0)then
        local childs = popupUI:GetChildren()
        for i = 0, childs.Length - 1 do
            local obj = childs[i].displayObject
            if(obj and obj.gameObject and obj.gameObject.name == "GoWrapper")then
                tabWrap[childs[i]] = 1
            end
            if(childs[i].numChildren and childs[i].numChildren > 0)then
                self:GetPopupUISpecial(childs[i], tabWrap)
            end
        end
    end
end

function PopupAnimTool:SetPopupCom(tabWrap)
    if(tabWrap)then
        for wrapCom, v in pairs(tabWrap)do
            if(wrapCom and wrapCom.displayObject and not Utils.unityTargetIsNil( wrapCom.displayObject.wrapTarget))then
                wrapCom.displayObject.wrapTarget:SetActive(false)
            end
        end
    end
end

function PopupAnimTool:ResetPopupCom(tabWrap)
    if(tabWrap)then
        for wrapCom, v in pairs(tabWrap)do
            if(wrapCom and wrapCom.displayObject and not Utils.unityTargetIsNil(wrapCom.displayObject.wrapTarget))then
                wrapCom.displayObject.wrapTarget:SetActive(true)
            end
        end
    end
end

return PopupAnimTool