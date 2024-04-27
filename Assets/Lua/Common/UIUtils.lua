local UIUtils = {}

-- 屏幕分辨率
UIUtils.ScreenResolution = CS.UnityEngine.Vector2(0, 0)
-- UI分辨率
UIUtils.UIResolution = CS.UnityEngine.Vector2(1080, 1920)
--[[
-- UI缩放系数
UIUtils.RootScaleFactor = 1
-- 舞台缩放系数
UIUtils.StageScaleFactor = 1
]]
-- 重连显示菊花间隔
UIUtils.ReConnectShowWaitingCd = 2

function UIUtils.initialize()
    UIUtils.SetResolution()
    UIUtils.RegisterFonts()
    -- ui相机
    CS.UnityEngine.GameObject.DontDestroyOnLoad(StageCamera.main)
    GRoot.inst.fairyBatching = true

    FUIConfig.buttonSoundVolumeScale = 0.5
    -- FUIConfig.richTextRowVerticalAlign = VertAlignType.Middle

    StageCamera.SetRendererIndex(3)
end

function UIUtils.RegisterFonts()
    -- 注册字体
    FUIConfig.defaultFont = "Source Han Sans CN"
    local defaultFontA = FontManager.GetFont("Source Han Sans CN")
    defaultFontA.customBold = true
    local defaultFontB = FontManager.GetFont("Source Han Serif SC")
    
    FontManager.RegisterFont(defaultFontA, "Source Han Sans CN")
    FontManager.RegisterFont(defaultFontA, "Source Han Sans CN")
    FontManager.RegisterFont(defaultFontA, "方正黑体简体")
    FontManager.RegisterFont(defaultFontA, "Noto Sans S Chinese Regular")
    FontManager.RegisterFont(defaultFontB, "Source Han Serif SC")
    FontManager.RegisterFont(defaultFontB, "GROBOLD")
end

function UIUtils.SetResolution()
    -- 屏幕分辨率
    UIUtils.ScreenResolution = CS.UnityEngine.Vector2(CS.UnityEngine.Screen.width, CS.UnityEngine.Screen.height)
    -- 自适应
    GRoot.inst:SetContentScaleFactor(UIUtils.UIResolution.x, UIUtils.UIResolution.y)

    --[[
    -- UI缩放系数
    local screenWidthScale, screenHeightScale =
        UIUtils.ScreenResolution.x / UIUtils.UIResolution.x,
        UIUtils.ScreenResolution.y / UIUtils.UIResolution.y
    if screenWidthScale > screenHeightScale then
        UIUtils.RootScaleFactor = 1 + ((screenWidthScale - screenHeightScale) / screenHeightScale)
    else
        UIUtils.RootScaleFactor = 1 + ((screenHeightScale - screenWidthScale) / screenWidthScale)
    end
    -- 舞台缩放系数
    UIUtils.StageScaleFactor = 1 / (Stage.inst.scaleX * GRoot.contentScaleFactor)
    ]]
end

function UIUtils.HtmlImg(url)
    return "<img src=\""..url.."\"/>"
end

local screenSafeArea = nil

local function ScreenSafeArea()
    if screenSafeArea then
        return screenSafeArea
    end

    local g = CS.UnityEngine.SystemInfo.deviceModel
    screenSafeArea = Screen.safeArea

    -- 机型列表 https://www.theiphonewiki.com/wiki/Models
    if (g == "iPhone10,3"
        or g == "iPhone10,6" --iPhoneX
        or g == "iPhone11,2" --iPhoneXS
        or g == "iPhone11,6" --iPhoneXSMax
        or g == "iPhone11,8" -- iPhoneXR
        or string.find(g, "iPhone12") == 1) then -- iPhone11 系列 
        -- iphone取状态栏高度
        screenSafeArea.yMax = Screen.height - 30 * Screen.height / 812
    elseif string.find(g, "iPhone13") == 1 then
        screenSafeArea.yMax = Screen.height - 28 * Screen.height / 812
    end
    return screenSafeArea
end

-- 安全边界
local function ScreenSafeEdge()
    local safeArea = ScreenSafeArea()

    return {
        left = safeArea.x,
        right = Screen.width - safeArea.xMax,
        bottom = safeArea.yMin,
        top = Screen.height - safeArea.yMax
    }
end

function UIUtils.SetUIFitScreen(ui, safe)
    if safe then
        local safeArea = ScreenSafeArea()
        ui:SetPosition(safeArea.x / UIContentScaler.scaleFactor, (Screen.height - safeArea.yMax) / UIContentScaler.scaleFactor)
        ui:SetSize(safeArea.width / UIContentScaler.scaleFactor,  safeArea.height / UIContentScaler.scaleFactor)
    else
        ui:SetSize(Screen.width / UIContentScaler.scaleFactor,  Screen.height / UIContentScaler.scaleFactor)
    end
    ui:AddRelation(GRoot.inst, RelationType.Size);
end

UIUtils.ScreenSafeArea = ScreenSafeArea
UIUtils.ScreenSafeEdge = ScreenSafeEdge

function UIUtils.SetGuildLayerMaskPos(ui)
    --ui.xy = Vector2(ui.xy.x ,ui.xy.y - UIUtils.IPhoneXBarWidth)
end

local ButtonGM

-- 实例化GM入口悬浮球
function UIUtils.ShowGMButton()
    if ButtonGM then return end
    
    local handler = UIManager.CreateFairyCom("UI/GMTools/GMTools", "GMTools", "Button_GM", false, function(ui, pkgId)
        ButtonGM = ui
            
        local safeArea = Screen.safeArea
        ui:SetPosition(safeArea.x * UIContentScaler.scaleFactor + 100, (Screen.height - safeArea.yMax) / UIContentScaler.scaleFactor + 100)

        ButtonGM.visible = true
        ButtonGM.opaque = false
        ButtonGM.draggable = true
        ButtonGM.sortingOrder = UISortOrder.GM
        ButtonGM.onClick:Add(function()
            UIManager.OpenUI(UIInfo.GmOrderUI)
        end)
    end)

    ButtonGM = ButtonGM or handler
end

--_conrtoller FairyGui.Controller,_index number
function UIUtils.SetControllerIndex(_conrtoller, _index)
    if _conrtoller == nil or _index == nil or type(_index) ~= "number" then
        Utils.DebugWarning(
            "setControllerIndex,has invalid value. _conrtoller,_index:",
            pcall(_conrtoller and _conrtoller.pageCount),
            _index
        )
        return
    end
    if _index >= 0 and _index < _conrtoller.pageCount then
        _conrtoller.selectedIndex = _index
    end
end

-- 加载图标
-- isButton时使用icon字段
function UIUtils.LoadIcon(loader, icon, isButton, pkgName)
    if nil == icon or Utils.uITargetIsNil(loader) then return end

    local iconPre = pkgName and string.format("ui://%s/", pkgName) or UIInfo.Library.UIImgPre
    local path = string.format("%s%s", iconPre, icon)
    if isButton then
        loader.icon = path
    else
        loader.url = path
    end
end

-- 填充货币图标
function UIUtils.FillResBtn(btn, resType, resNum)
    if Utils.uITargetIsNil(btn) then return end

    if resType == CommonCostType.Coin then
        UIUtils.LoadIcon(btn, "金币", true)
    elseif resType == CommonCostType.Diamond then
        UIUtils.LoadIcon(btn, "钱", true)
    end

    if resNum then
        btn.text = Utils.ResourceHandler(resNum)
    end
end

-- 语言文字图片
function UIUtils.LangIcon(loader, icon)
    if nil == icon or Utils.uITargetIsNil(loader) then return end

    local locname = string.lower(LocalizationMgr.GetCurrLanguageType().name)
    if locname ~= "cn" then
        icon = icon .. "_" .. locname
    end
    loader.url = icon
end

-- 计算UI系统内的向量夹角
function UIUtils.calcAngle(direA, direB)
    if nil == direA or nil == direB or direA == Vector2.zero or direB == Vector2.zero then
        return 0
    end

    local angle = Vector2.Angle(direA, direB)
    local factor = 1
    if Vector3.Cross(Vector3(direA.x,direA.y,0), Vector3(direB.x,direB.y,0)).z < 0 then
        factor = -1
    end

    return angle * factor
end

-- 货币特效
function UIUtils.MoneyEffect(rewardType, btn, offset)
    if nil == rewardType then return end
    
    local m_startpos
    if btn then
        offset = offset or btn.size / 2
        m_startpos = btn:LocalToRoot(offset)
    else
        m_startpos = UIUtils.ScreenResolution * 0.5
    end
    local effectType = rewardType == 1 and ClickEffectType.CollectGold or ClickEffectType.DiamondEffect
    local mainui = UIManager.GetUI(UIInfo.MainUI.UIComName).MainTopUI
    local theicon = rewardType == 1 and mainui.GoldIcon or mainui.diamondIcon
    local m_targetpos = rewardType == 1 and theicon:LocalToRoot(Vector2.zero) or theicon:LocalToRoot(theicon.size / 2)
    local angle = UIUtils.calcAngle(m_targetpos - m_startpos, Vector2.down)
    local scale = rewardType == 1 and 1.5 or 2
    local yOffset = scale*6.28

    m_startpos = m_startpos + (m_targetpos -m_startpos).normalized *scale*(rewardType == 1 and 200 or 300)
    UIManager.ShowEffect(
        effectType,m_startpos,
        UISortOrder.ClickEffect, Vector3(-yOffset*math.sin(-angle*math.pi/180),-yOffset*math.cos(-angle*math.pi/180),0), scale,
        {startpos = m_startpos, targetpos = m_targetpos, rotation = Vector3(0,0,angle)}
    )
end

-- 获取从相机指向视图中心的射线
function UIUtils.ViewCenterToRay(mainCamera)
    mainCamera = mainCamera or CS.UnityEngine.Camera.main
    local ray
    if PlayerData.bottomListFolded then
        ray = mainCamera:ScreenPointToRay(Vector3(Screen.width / 2, (Screen.height + UIUtils.ViewHeightFold) / 2, 0))
    else
        ray = mainCamera:ScreenPointToRay(Vector3(Screen.width / 2, (Screen.height + UIUtils.ViewHeightUnfold) / 2, 0))
    end
    
    return ray
end

function UIUtils.Dispose()
    if ButtonGM then
        ButtonGM.onClick:Clear()
    end
end

return UIUtils
