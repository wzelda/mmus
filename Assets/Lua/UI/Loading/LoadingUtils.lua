
local LoadingUtils = {}

local minRan = 3
local maxRan = 13

LoadingUtils.useLast = false

function LoadingUtils:GetGuideContent(id)
       
    -- if id >= 2 and id <= 12 then

    --     return LocalizeExt(id - 1 + 21420)
    -- elseif 13 == id then

    --     return LocalizeExt(21542)
    -- end
    
    return ""
end

function LoadingUtils:GetImgUrl(fromLogin,toLogin)

    if toLogin then
        
        self.id = 0

    else
        
        -- if(fromLogin)then
            
            self.id = 1

        -- else
            
        --     if LoadingUtils.useLast then

        --     else

        --         local setID = PlayerData.Datas.UserMiscData.ClientSetting[ESoftGuideCheck.LoadingImg]

        --         if setID == nil then
                    
        --             self.id = 2
        --             PlayerData.Datas.UserMiscData:RequestClientSetting(ESoftGuideCheck.LoadingImg,2)
        --         else
                
        --             self.id = setID + 1

        --             if self.id > 13 then
                        
        --                 self.id = math.random(minRan,maxRan)

        --             else
                        
        --                 PlayerData.Datas.UserMiscData:RequestClientSetting(ESoftGuideCheck.LoadingImg,self.id)

        --             end
                
        --         end    

        --     end

        -- end

    end
    
    self.UseImg = "UIImage/Loading/ui_loading_guide_"..tostring(self.id)
    return self.id,self.UseImg
end


return LoadingUtils