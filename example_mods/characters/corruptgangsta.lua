-- THIS SCRIPT USES PSYCH ENGINE 0.6.1 AND LATER ONLY
-- author: TheLeerName
-- source: https://gamebanana.com/tools/9815
function onCreatePost()
	addHaxeLibrary('FlxTrail', 'flixel.addons.effects') -- adds FlxTrail library for hscript interpreter (MUST ADD FIRST)

	runHaxeCode('dadtrail = new FlxTrail(game.dad, null, 5, 6, 0.3, 0.002)') -- sets ghost trail of dad via FlxTrail library, below the explanation of values
	-- new FlxTrail(Target:FlxSprite, ?Graphic:Null<FlxGraphicAsset>, Length:Int = 10, Delay:Int = 3, Alpha:Float = 0.4, Diff:Float = 0.05)
	-- "game." is necessary if you sets value from game

	runHaxeCode('game.addBehindDad(dadtrail)') -- adds ghost trail of dad


	-- for boyfriend
	runHaxeCode('bftrail = new FlxTrail(game.boyfriend, null, 5, 6, 0.3, 0.002)')
	runHaxeCode('game.addBehindBF(bftrail)')


	-- for girlfriend
	runHaxeCode('gftrail = new FlxTrail(game.gf, null, 5, 6, 0.3, 0.002)')
	runHaxeCode('game.addBehindGF(gftrail)')
end

function onBeatHit()
	if curBeat == 224 then
		runHaxeCode('dadtrail.visible = false')
		runHaxeCode('bftrail.visible = false')
		runHaxeCode('gftrail.visible = false')
end
    if curBeat == 288 then
		runHaxeCode('dadtrail.visible = true')
		runHaxeCode('bftrail.visible = true')
		runHaxeCode('gftrail.visible = true')
	end
end