-- 全屏Loading界面

local LoadingPanel = UIManager.PanelFactory(UIInfo.LoadingUI)
LoadingPanel.HidePrePanel = false
LoadingPanel.curP = nil
LoadingPanel.nextP = nil
LoadingPanel.isFirst = false
local panel = nil

-- 进度
local function updateProgressInfo(p)
    if panel.nextP < p then
        panel.nextP = p
        panel.expectedSpeed = (p - panel.curP) * 3
    end
end

-- 结束
local function loadComplete()
    UIManager.CloseUI(UIInfo.LoadingUI)
end
 --local time1 = nil 
 --local time2 = nil
-- 子类初始化UI控件
function LoadingPanel:OnOpen(args)
    args = args or {}
    local parent = self.UI.parent

    self.SortingOrder = UISortOrder.Waiting
    self.UI.sortingOrder = UISortOrder.Waiting

    --Utils.DebugError("LoadingPanel:OnOpen")
    panel = self
    self.isFirst = args.isFirst
    --time1 = Time.realtimeSinceStartup
    UIUtils.LangIcon(self.UI:GetChild("icon"), "ui://Loading/logo")
    if not Utils.IsCN() then
        self.UI:GetChild("n2").text = ""
    end
    local window = self.UI:GetChild("Window")
    if self.processbar == nil then
        self.processbar = window:GetChild("Bar")   
        self.processbar.value = 0

        -- 提审状态需要隐藏Loading进度条，等过审之后显示Loading条
        local tishenzhong = false

        if tishenzhong then
            if Application.platform ~= RuntimePlatform.IPhonePlayer or PlayerPrefs.GetString("LaunchMode") == "gmkaiqi" then
                tishenzhong = false
            end
        end

        self.processbar.visible = not tishenzhong
    end
    window:GetChild("n3").visible = false
    
    self.processbar.max = 100
    UIManager.loadingPanel = self
    self.curP = self.processbar.value or 0
    self.nextP = 0
    
    self.guidelabel = window:GetChild("GuideTipLabel")
    --local logoCtrl = window:GetController("GuideLabelCtrl")
    --self.bgLoader = window:GetChild("Img_Loader")

    --self.id,self.url = LoadingUtils:GetImgUrl(args.fromLogin, args.toLogin)

    --logoCtrl.selectedIndex = self.id
    --self.bgLoader.url = self.url    
    self.loadingTasks = {}
    self.loadStep = 1
    self.expectedSpeed = 1
end

function LoadingPanel:AddTask(endPercent, expectedTime)
    local startPercent = 0
    if #self.loadingTasks > 0 then
        startPercent = self.loadingTasks[#self.loadingTasks].endPercent
    end

    local expectedSpeed = self.expectedSpeed or 1
    if expectedTime then
        expectedSpeed = (endPercent - startPercent) / expectedTime
    end

    local task = {
        startPercent = startPercent,
        endPercent = endPercent,
        expectedSpeed = expectedSpeed
    }

    table.insert(self.loadingTasks, task)

    if self.loadStep == #self.loadingTasks and self.loadStep == 1 then
        self.expectedSpeed = expectedSpeed
    end

    return task
end

function LoadingPanel:AddCustomTask(endPercent, expectedTime)
    endPercent = endPercent or 1
    local task = self:AddTask(endPercent, expectedTime)

    function task.getProgress(t)
        return t.percent or 0
    end

    function task.setLocalProgress(t, percent)
        t.percent = t.startPercent + (t.endPercent - t.startPercent) * percent
    end

    function task.isComplete(t)
        return t.isDone
    end

    return task
end

function LoadingPanel:AddAsyncOperation(asyncOperation, endPercent, expectedTime)
    endPercent = endPercent or 1
    local task = self:AddTask(endPercent, expectedTime)

    task.asyncOperation = asyncOperation

    function task.getProgress(t)
        return t.startPercent + (t.endPercent - t.startPercent) * t.asyncOperation.PercentComplete
    end

    function task.isComplete(t)
        return t.asyncOperation.IsDone
    end

    return task
end

function LoadingPanel:RefreshText()
    --[[
    self.guidelabel.visible = true
    if self.id == 0 or self.id == 1 then    
        self.guidelabel.visible = false
    else
        self.guidelabel.text = LoadingUtils:GetGuideContent(self.id)
    end
    ]]
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function LoadingPanel:OnRefresh(...)
end

function LoadingPanel:OnUpdate()
    if self.curP == nil or self.curP > 100 or panel == nil then
        return
    end

    if #self.loadingTasks > 0 then
        local curTask = self.loadingTasks[self.loadStep]

        if curTask then
            if curTask:isComplete() then
                if curTask.endPercent >= 1 and #self.loadingTasks == self.loadStep then
                    loadComplete()
                    return
                else
                    self.loadStep = self.loadStep + 1
                end
            else
                updateProgressInfo(curTask:getProgress() * 100)
            end
        end
    end

    local deltaTime = TimerManager.deltaTime
    self.curP = self.curP + deltaTime * self.expectedSpeed * 100

    if self.curP > self.nextP then
        self.curP = self.nextP
    end

    if self.processbar.value < self.curP then
        self.processbar.value = self.curP
        if self.curP >= 99 then
            self.curP = 100
        end
    end
end

-- 关闭
function LoadingPanel:OnClose()
    --Utils.DebugError("LoadingPanel:OnClose")
    panel = nil
    --self.bgLoader.url = ""
    if not self.isFirst then
        self.processbar.value = 0
    end

    self.curP = 0
    self.nextP = 0
    self.processbar.max = 100
    UIManager.loadingPanel = nil
end

return LoadingPanel
--endregion
