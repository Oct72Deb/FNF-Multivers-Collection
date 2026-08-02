function onCreate()
    setProperty('boyfriend.alpha',0)
    setProperty('dad.alpha',0)
    setProperty('gf.alpha',0)

end

function onBeatHit() 
    setProperty('monika.y',0)
    doTweenY('assamonika','monika',-30,0.5,'quartOut')

     setProperty('sayori.y',0)
    doTweenY('asssayori','sayori',-30,0.5,'quartOut')

    setProperty('yuri.y',0)
    doTweenY('assyuri','yuri',-30,0.5,'quartOut')

         setProperty('natsuki.y',0)
    doTweenY('natsu','natsuki',-30,0.5,'quartOut')
end