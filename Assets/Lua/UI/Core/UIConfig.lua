local UIConfig = {}

-- 表情
UIEmojiCount = 13
UIEmojiPerPageCount = 10
UIEmojiUrl = "UIImage/Emoji/"
UISkin = "UIImage/Skin/"
UIEmptyUrl = "UIImage/Common/ui_img_tooltipNPC"

UISortOrder = {
    FuncLock = 0,
    ConfirmBuy = 600,
    ResEffect = 700,
    UpgradePanel = 750,
    NewGuide = 1040,
    PopupUI = 1050,
    ClickEffect = 1052,
    Waiting = 1100,
    MsgTips = 1110,
    GM = 1111,
}

UIConfig.BottomListHeight=nil

UIInfo = {
    -- 图集
    Library = {
        UIPackagePath = "UI/Library/Library",
        UIName = "Library",
        UIImgPre = "ui://Library/" -- 图片资源前缀
    },
    --功能未开放的锁
    FuncLockUI = {
        UIPackagePath = "UI/FunctionLock/FunctionLock",
        UIName = "FunctionLock",
        UIComName = "FunctionLock",
        UILogic = "UI.FunctionLock.FunctionLockUI",
    },
    Tools = {
        UIPackagePath = "UI/Tools/Tools",
        UIName = "Tools",
        UIImgPre = "ui://Tools/" -- 图片资源前缀
    },
    BattleLabel = {
        UIPackagePath = "UI/BattleLabel/BattleLabel",
        UIName = "BattleLabel",
        UIComName = "JumpWordMap",
        UIImgPre = "ui://BattleLabel/" -- 图片资源前缀
    },
    ResourcesIcon = {
        UIPackagePath = "UI/ResourcesIcon/ResourcesIcon",
        UIName = "ResourcesIcon",
        UIImgPre = "ui://ResourcesIcon/"
    },
    ItemIcon = {
        UIPackagePath = "UI/ItemIcon/ItemIcon",
        UIName = "ItemIcon",
        UIImgPre = "ui://ItemIcon/"
    },
    MiniMapIcon = {
        UIImgPre = "UIImage/MiniMap/",
    },
    ShopIcon = {
        UIPackagePath = "UI/ShopIcon/ShopIcon",
        UIName = "ShopIcon",
        UIImgPre = "ui://ShopIcon/"
    },
    -- 用品
    GoodsIcon = {
        UIPackagePath = "UI/GoodsIcon/GoodsIcon",
        UIName = "GoodsIcon",
        UIImgPre = "ui://GoodsIcon/"
    },
    -- 玩家头像
    HeadIcon = {
        UIPackagePath = "UI/HeadIcon/HeadIcon",
        UIName = "HeadIcon",
        UIImgPre = "ui://HeadIcon/"
    },
    -- loading加载界面
    LoadingUI = {
        UIPackagePath = "UI/Loading/Loading",
        UIName = "Loading",
        UIComName = "Loading",
        UILogic = "UI.Loading.LoadingPanel",
        UIImgPre = "UIImage/Loading/",
        DontPlayUIOpenSound = true,
        CantClose = true
    },
    -- Waiting等待界面
    WaitingUI = {
        UIPackagePath = "UI/Library/Library",
        UIName = "Library",
        UIComName = "Waiting",
        UILogic = "UI.Tools.Waiting"
    },
    -- 弹出窗
    PopupUI = {
        UIPackagePath = "UI/CommonWindow/CommonWindow",
        UIName = "CommonWindow",
        UIComName = "PopupUI",
        UILogic = "UI.Tools.PopupUI",
        DontPlayUIOpenSound = true,
        PopupAnim = true
    },
    -- 鱼，装饰物展示弹出窗
    ShowFishInfoUI = {
        UIPackagePath = "UI/ShowInfo/ShowInfo",
        UIName = "ShowInfo",
        UIComName = "ShowInfo",
        UILogic = "UI.Tools.ShowFishInfoUI",
        DontPlayUIOpenSound = true,
        PopupAnim = true
    },
    --设置界面
    GameSettingsUI = {
        UIPackagePath = "UI/GameSettings/GameSettings",
        UIName = "GameSettings",
        UIComName = "GameSettings",
        UILogic = "UI.GameSettings.GameSettingsPanel",
        DontPlayUIOpenSound = true
    },
    -- 疲劳提示弹出窗
    TiredPopupUI = {
        UIPackagePath = "UI/Tools/Tools",
        UIName = "Tool",
        UIComName = "TiredPopupUI",
        UILogic = "UI.Tools.TiredPopupUI",
        DontPlayUIOpenSound = true
    },
    -- 主界面
    MainUI = {
        UIPackagePath = "UI/MainCity/MainCity",
        UIName = "MainCity",
        UIComName = "MainCity",
        UILogic = "UI.Main.MainPanel",
        IsFullScreen = false,
        OpenAudio = true,
        ShowBgAudioEffect = true,
        DontPlayUIOpenSound = true
    },
    -- 主界面
    MainBottomUI = {
        UIPackagePath = "UI/MainCity/MainCity",
        UIName = "MainCity",
        UIComName = "Sub_Bottom",
        UILogic = "UI.Main.MainBottomUI",
        DontPlayUIOpenSound = true,
        IsFullScreen = false
    },
    MainTopUI = {
        UIPackagePath = "UI/MainCity/MainCity",
        UIName = "MainCity",
        UIComName = "Sub_Top",
        UILogic = "UI.Main.MainTopPanel",
        DontPlayUIOpenSound = true
    },
    AquariumShowList = {
        UILogic = "UI.Main.AquariumShowList",
    },
    FishList = {
        UILogic = "UI.Main.FishList",
    },
    PhotoUI = {
        UIPackagePath = "UI/Photo/Photo",
        UIName = "Photo",
        UIComName = "PhotoMain",
        UILogic = "UI.Photo.PhotoPanel",
    },
    AquariumSelectUI = {
        UIPackagePath = "UI/Aquarium/Aquarium",
        UIName = "Aquarium",
        UIComName = "Aquarium",
        UILogic = "UI.Aquarium.AquariumSelectPanel",
    },
    ItemPopupUI = {
        UIPackagePath = "UI/CommonWindow/CommonWindow",
        UIName = "CommonWindow",
        UIComName = "PopupWindow",
        UILogic = "UI.Tools.ItemPopUI",
        PopupAnim = true,
    },
    ShipFishUI = {
        UIPackagePath = "UI/Catch/Catch",
        UIName = "Catch",
        UIComName = "Catch",
        UILogic = "UI.ShipFish.ShipFish",
        PopupAnim = true,
    },
    FishGrowthUI = {
        UIPackagePath = "UI/CommonWindow/CommonWindow",
        UIName = "CommonWindow",
        UIComName = "Grow",
        UILogic = "UI.Main.FishGrowthUI",
        PopupAnim = true,
    },

    IncomeUI = {
        UIPackagePath = "UI/Tips/Tips",
        UIName = "Tips",
        UIComName = "TipsIncome",
        UILogic = "UI.Main.IncomeUI",
        DontPlayUIOpenSound = true
    },
    -- 通用特效 在ui界面上某个位置展示特效
    TipsUI = {
        UIPackagePath = "UI/Tips/Tips",
        UIName = "Tips",
        UIComName = "TipsMain",
        UILogic = "UI.Tools.Tips",
        DontPlayUIOpenSound = true
    },
    -- GM界面
    GmOrderUI = {
        UIPackagePath = "UI/GMTools/GMTools",
        UIName = "GMTools",
        UIComName = "GMMain",
        UILogic = "UI.GMTools.GmOrder",
        IsFullScreen = false,
        DontPlayUIOpenSound = true
    },
    InformationUI = {
        UIPackagePath = "UI/Information/Information",
        UIName = "Information",
        UIComName = "Information",
        UILogic = "UI.Information.InformationPanel",
        DontPlayUIOpenSound = true,
        PopupAnim = true,
    },
    FishFightUI = {
        UIPackagePath = "UI/FishFightTemp/FishFightTemp",
        UIName = "FishFightTemp",
        UIComName = "FishFight",
        UILogic = "UI.FishFight.FishFightUI",
    },
    OfflineTimeUI = {
        UIPackagePath = "UI/OfflineTime/OfflineTime",
        UIName = "OfflineTime",
        UIComName = "OfflineTime",
        UILogic = "UI.OfflineTime.OfflineTimePanel",
        PopupAnim = true,
    },
    ImproveUI = {
        UIPackagePath = "UI/Improve/Improve",
        UIName = "Improve",
        UIComName = "Improve",
        UILogic = "UI.Improve.ImproveTab",
        ChildIndex = 0,
    },
    ImproveBreakUI = {
        UIPackagePath = "UI/Improve/Improve",
        UIName = "Improve",
        UIComName = "Title",
        UILogic = "UI.Improve.ImproveBreakUI",
        ChildIndex = 0,
    },
    EarthUI = {
        UIPackagePath = "UI/Earth/Earth",
        UIName = "Earth",
        UIComName = "Earth",
        UILogic = "UI.Earth.EarthUI",
        ChildIndex = 0,
    },
    OceanAeraUI = {
        UIPackagePath = "UI/Earth/Earth",
        UIName = "Earth",
        UIComName = "OceanAera",
        UILogic = "UI.Earth.OceanAeraUI",
        PopupAnim = true,
    },
    ShipTreasureUI = {
        UIPackagePath = "UI/ShipTreasure/ShipTreasure",
        UIName = "ShipTreasure",
        UIComName = "ShipTreasureUI",
        UILogic = "UI.ShipTreasure.ShipTreasureUI",
        PopupAnim = true,
    },
    AchievementUI = {
        UIPackagePath = "UI/Achievement/Achievement",
        UIName = "Achievement",
        UIComName = "Achievement",
        UILogic = "UI.Achievement.AchievementTab",
        IsFullScreen = false,
    },
    AchieveAwardTitleUI = {
        UIPackagePath = "UI/Achievement/Achievement",
        UIName = "Achievement",
        UIComName = "Achievement_AwardTitle",
        UILogic = "UI.Achievement.AchieveAwardTitleUI",
        PopupAnim = true,
    },
    AchieveTitleUI = {
        UIPackagePath = "UI/Achievement/Achievement",
        UIName = "Achievement",
        UIComName = "Achievement_TitleList",
        UILogic = "UI.Achievement.AchieveTitleUI",
        PopupAnim = true,
    },
    MainTaskUI = {
        UIPackagePath = "UI/Task/Task",
        UIName = "Task",
        UIComName = "TaskWindow",
        UILogic = "UI.Task.MainTaskUI",
        PopupAnim = true,
    },
    -- 引导遮罩页面
    GuideLayer = {
        UIPackagePath = "UI/Guide/Guide",
        UIName = "Guide",
        UIComName = "GuideLayer",
        UILogic = "UI.Guide.GuideLayer",
        DontPlayUIOpenSound = true,
        DisposeUI = true,
    },
    StoryPanel = {
        UIPackagePath = "UI/Story/Story",
        UIName = "Story",
        UIComName = "Story",
        UILogic = "UI.Story.StoryPanel",
        DontPlayUIOpenSound = true,
        DisposeUI = true,
    },
}

return UIConfig