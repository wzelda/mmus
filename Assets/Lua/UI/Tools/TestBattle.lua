--GM测试战斗UI
local TestBattle = class()
TestBattle.view = nil
TestBattle.viewPkgId = nil
TestBattle.heroPosComTable = nil
TestBattle.heroIds = nil

TestBattle.HeroNameList = nil
TestBattle.HeroValueList = nil
TestBattle.dragonNameList = nil
TestBattle.dragonValueList = nil
TestBattle.SceneNameList = nil
TestBattle.SceneValueList = nil

TestBattle.key = "TestBattleFormation"

function TestBattle:OnShow()
    if(self.HeroNameList == nil)then
        if(ConfigData.config)then
            self.HeroNameList = {"无"}
            self.HeroValueList = {0}
            table.sort( ConfigData.config.hero_datas, function(a, b)
                return a.order_id < b.order_id
            end )
            for i, heroData in ipairs(ConfigData.config.hero_datas)do
                if(heroData.handbook_on)then
                    table.insert( self.HeroNameList, LocalizeExt(heroData.name))
                    table.insert( self.HeroValueList, heroData.id)
                end
            end
            self.dragonNameList = {"无"}
            self.dragonValueList = {0}
            for i, dragonData in ipairs(ConfigData.config.dragon_datas)do
                table.insert( self.dragonNameList, LocalizeExt(dragonData.name))
                table.insert( self.dragonValueList, dragonData.type)
            end
            self.SceneNameList = {"Scene01","Scene02","Scene03","Scene04","Scene05","Scene06","Scene07","Scene08","Scene09","Scene10","Scene11","Scene13","Scene14"}
            self.SceneValueList = self.SceneNameList
        else
            return
        end
    end
    if(not self.view)then
        self.view,self.viewPkgId = UIManager.CreateFairyCom(UIInfo.GmOrderUI.UIPackagePath,UIInfo.GmOrderUI.UIName,"TestBattle")
        self.view.sortingOrder = 901
        --关闭按钮
        local bg = self.view:GetChild("CloseBtn")
        bg.onClick:Add(function() 
            self.view.visible = false
        end)

        --布阵输入框
        self.heroPosComTable = {}
        for i = 1, 12 do
            local PopCom = self.view:GetChild("Pos"..i):GetChild("PopCom")
            PopCom.items = self.HeroNameList
            PopCom.values  = self.HeroValueList
            local posTextChanged = function()

            end
            PopCom.onChanged:Add(posTextChanged)
            table.insert(self.heroPosComTable, PopCom)
        end
        self.selfDragonCom = self.view:GetChild("SelfDragon"):GetChild("PopCom")
        self.selfDragonCom.items = self.dragonNameList
        self.selfDragonCom.values  = self.dragonValueList
        --self.selfDragonCom:GetChild("Text_Title").onChanged:Add(dragonTextChange)
        self.enemyDragonCom = self.view:GetChild("EnemyDragon"):GetChild("PopCom")
        self.enemyDragonCom.items = self.dragonNameList
        self.enemyDragonCom.values  = self.dragonValueList
        --self.enemyDragonCom:GetChild("Text_Title").onChanged:Add(dragonTextChange)
        self.heroLevelText = self.view:GetChild("HeroLevel"):GetChild("Text_Title")
        self.heroStarText = self.view:GetChild("HeroStar"):GetChild("Text_Title")
        self.heroLevelText1 = self.view:GetChild("HeroLevel1"):GetChild("Text_Title")
        self.heroStarText1 = self.view:GetChild("HeroStar1"):GetChild("Text_Title")
        --输入最近记录
        self.formation = Utils.GetData(self.key) or { heroIds = {}, selfDragon = 0, enemyDragon = 0 , heroLevel = 100, heroStar = 0, heroLevel1 = 100, heroStar1 = 0}
        for i, posCom in ipairs(self.heroPosComTable)do
            posCom.value = self.formation.heroIds[i] or 0
        end 
        self.selfDragonCom.value = self.formation.selfDragon or 0
        self.enemyDragonCom.value = self.formation.enemyDragon or 0
        self.heroLevelText.text = self.formation.heroLevel or 100
        self.heroStarText.text = self.formation.heroStar or 0
        self.heroLevelText1.text = self.formation.heroLevel1 or 100
        self.heroStarText1.text = self.formation.heroStar1 or 0
        --场景选择
        local sceneLabel = self.view:GetChild("sceneLabel")
        sceneLabel.items = self.SceneNameList
        sceneLabel.values  = self.SceneValueList
        --战斗按钮
        local battleBtn = self.view:GetChild("BattleBtn")

        local battleSubmit = function()
            --校验数据
            local isLegal = nil
            local formation, isLegal = self:CollectHeroIds()
            Utils.SaveData(self.key, formation)
            --两边度必须上阵英雄
            if(not isLegal)then
--                UIManager.ShowMsg("两边都需要上阵英雄")
                UIManager.ShowMsg(LocalizeExt(21375))
                return
            end
            --自定义场景数据
            local sceneData = ConfigData:FindSceneDataByName(sceneLabel.value)
            if(not sceneData)then 
--                UIManager.ShowMsg("场景名字不对，采用默认场景")
                UIManager.ShowMsg(LocalizeExt(20053))
                sceneData = ConfigData:FindSceneDataByName("Scene07") 
            end
            --发送队伍数据，请求测试战斗
            --UIManager.OpenUI(UIInfo.LoadingUI)
            --EventDispatcher:Add(Event.NET_ERROR, BattleManager.SystemToBattleFailedFunc, BattleManager)
            BattleManager:EnterTestBattle2(sceneData.id, formation.heroIds, {formation.selfDragon, formation.enemyDragon}, formation.heroLevel, formation.heroStar, formation.heroLevel1, formation.heroStar1)
            self.view.visible = false
        end
        battleBtn.onClick:Add(battleSubmit)
    end
    self.view.visible = true
    
end

--收集英雄ID
function TestBattle:CollectHeroIds()
    local hasFriendHero = false
    local hasEnemyHero = false
    local formation = {}
    local heroIds = {}
    for i, posCom in ipairs(self.heroPosComTable)do
        local heroId = posCom.value
        heroIds[i] = heroId
        if(i <= 6)then
            hasFriendHero = true
        else
            hasEnemyHero = true
        end
    end
    formation.heroIds = heroIds
    formation.selfDragon = self.selfDragonCom.value 
    formation.enemyDragon = self.enemyDragonCom.value 
    formation.heroLevel = tonumber(self.heroLevelText.text)
    formation.heroStar = tonumber(self.heroStarText.text)
    formation.heroLevel1 = tonumber(self.heroLevelText1.text)
    formation.heroStar1 = tonumber(self.heroStarText1.text)
    return formation, hasFriendHero and hasEnemyHero
end

function TestBattle:OnClose()
    if(self.view)then
        self.selfDragonCom.onChanged:Clear()
        self.enemyDragonCom.onChanged:Clear()
        UIManager.DisposeFairyCom(self.viewPkgId,self.view)
        self.selfDragonCom = nil
        self.enemyDragonCom = nil
        self.heroPosComTable = nil
    end
end

return TestBattle