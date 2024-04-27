-- 动画项
local PopupAnimItem = class()
PopupAnimItem.popUI = nil
PopupAnimItem.itemParamList = nil
PopupAnimItem.completeCallBack = nil
PopupAnimItem.animTimer = nil
PopupAnimItem.isComplete = nil

local Mathf = CS.UnityEngine.Mathf
local Vector3 = CS.UnityEngine.Vector3

function PopupAnimItem:Play(popUI, itemParamList, completeCallBack)
    self.popUI = popUI
    self.itemParamList = itemParamList
    self.completeCallBack = completeCallBack
    self.maxCd = 0
    --动画最大时间
    for i, itemParam in ipairs(itemParamList)do
        if(itemParam.EndTime > self.maxCd)then
            self.maxCd = itemParam.EndTime
        end
    end
    self.animTimer = TimerManager.newTimer(self.maxCd, false, true, self.AnimStart, self.AnimUpdate, self.AnimComplete, self, false)
    self.animTimer:start()
    self.isComplete = false
end

function PopupAnimItem:AnimStart()
    --Update没有第一帧，这里模拟
    self:AnimUpdate(self.maxCd)
end
-- AnimType 0:无效果， 1：缩放， 2：透明
function PopupAnimItem:AnimUpdate(CurCd)
    if(Utils.uITargetIsNil(self.popUI))then
        self:AnimComplete()
        return
    end
    local t = self.maxCd - CurCd
    for i, itemParam in ipairs(self.itemParamList)do
        if(itemParam.AnimType == 3)then
            if(itemParam.StartTime > t and itemParam.HasExe == false)then
                itemParam.HasExe = true
                itemParam.EventFunc()
            end
        else
            local p = (t - itemParam.StartTime) /(itemParam.EndTime - itemParam.StartTime)
            if(itemParam.AnimType == 1)then
                self.popUI.scale = Vector2.Lerp(itemParam.StartValue, itemParam.EndValue, p)
            elseif(itemParam.AnimType == 2)then
                self.popUI.alpha = Mathf.Lerp(itemParam.StartValue, itemParam.EndValue, p)
            end
        end
    end
end

function PopupAnimItem:AnimComplete()
    if(not self.isComplete)then
        self.isComplete = true
        if(self.completeCallBack)then
            self.completeCallBack()
        end
        TimerManager.disposeTimer(self.animTimer)
        self.animTimer = nil
        self.completeCallBack = nil
        self.itemParamList = nil
        self.popUI = nil
    end
end

function PopupAnimItem:Stop()
    self:AnimComplete()
end


return PopupAnimItem