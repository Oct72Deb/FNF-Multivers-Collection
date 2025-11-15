function onCreate()
    if songName == 'Allocution' then
        makeLuaSprite('healthbarFR', 'hud/healthbar/healthbar_fr', 215, 625)
        scaleObject('healthbarFR', 0.81, 0.81)
        addLuaSprite('healthbarFR', true)
        setObjectCamera("healthbarFR", "camHUD")
    end

    if songName == 'Periple' then
        makeLuaSprite('healthbardefault', 'hud/healthbar/healthbar_default', 225, 603)
        scaleObject('healthbardefault', 0.81, 0.81)
        addLuaSprite('healthbardefault', true)
        setObjectCamera("healthbardefault", "camHUD")
    end

    if songName == 'How to Play' then
        makeLuaSprite('healthbarsmash', 'hud/healthbar/healthbar_smash', 320, 578)
        scaleObject('healthbarsmash', 0.41, 0.41)
        addLuaSprite('healthbarsmash', true)
        setObjectCamera("healthbarsmash", "camHUD")
    end

    if songName == 'Metal Reflection' then
        makeLuaSprite('healthbarsmash', 'hud/healthbar/healthbar_smash', 207, 608)
        scaleObject('healthbarsmash', 0.66, 0.66)
        addLuaSprite('healthbarsmash', true)
        setObjectCamera("healthbarsmash", "camHUD")
    end

    if songName == 'New Game' then
        makeLuaSprite('healthbarmadness', 'hud/healthbar/healthbar_madness', 252, 607)
        scaleObject('healthbarmadness', 0.82, 0.82)
        addLuaSprite('healthbarmadness', true)
        setObjectCamera("healthbarmadness", "camHUD")
    end

    if songName == 'Trick or Treating' then
        makeLuaSprite('healthbardoki', 'hud/healthbar/healthbar_doki', 320, 578)
        scaleObject('healthbardoki', 0.81, 0.81)
        addLuaSprite('healthbardoki', true)
        setObjectCamera("healthbardoki", "camHUD")
    end

    if songName == 'Trick or Treating Old' then
        makeLuaSprite('healthbardoki', 'hud/healthbar/healthbar_doki', 320, 578)
        scaleObject('healthbardoki', 0.81, 0.81)
        addLuaSprite('healthbardoki', true)
        setObjectCamera("healthbardoki", "camHUD")
    end

    if songName == 'Criminal Targets' then
        makeLuaSprite('healthbardefault', 'hud/healthbar/healthbar_smash', 235, 595)
        scaleObject('healthbardefault', 0.81, 0.81)
        addLuaSprite('healthbardefault', true)
        setObjectCamera("healthbardefault", "camHUD")
    end
end