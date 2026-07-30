-- Variables menu
local menuActive = true
local selectedOption = 1
local playAsOpponent = false
local versionAChosen = false

-- --- INIT MENU ---
function onCreate()
    makeLuaSprite('bgMenu', '', 0, 0)
    makeGraphic('bgMenu', 1280, 720, '000000')
    setProperty('bgMenu.alpha', 0.8)
    setObjectCamera('bgMenu', 'other')
    addLuaSprite('bgMenu', true)

    makeLuaText('menuTitle', 'CHOISISSEZ VOTRE VERSION', 1280, 0, 150)
    setTextSize('menuTitle', 60)
    setTextAlignment('menuTitle', 'center')
    setObjectCamera('menuTitle', 'other')
    addLuaText('menuTitle')

    makeLuaText('optA', '> Version A : Jouer l\'Adversaire <', 1280, 0, 350)
    setTextSize('optA', 40)
    setTextAlignment('optA', 'center')
    setTextColor('optA', 'FFFF00')
    setObjectCamera('optA', 'other')
    addLuaText('optA')

    makeLuaText('optB', 'Version B : Normal (Boyfriend)', 1280, 0, 450)
    setTextSize('optB', 40)
    setTextAlignment('optB', 'center')
    setObjectCamera('optB', 'other')
    addLuaText('optB')
end

-- --- BLOQUER LE COUNTDOWN SI MENU ACTIF ---
function onStartCountdown()
    if menuActive then return Function_Stop end
    return Function_Continue
end

-- --- MENU NAVIGATION ---
function onUpdate(elapsed)
    if not menuActive then return end

    if keyJustPressed('up') or keyJustPressed('down') then
        playSound('scrollMenu')
        if selectedOption == 1 then
            selectedOption = 2
            setTextString('optA', 'Version A : Jouer l\'Adversaire')
            setTextColor('optA', 'FFFFFF')
            setTextString('optB', '> Version B : Normal (Boyfriend) <')
            setTextColor('optB', 'FFFF00')
        else
            selectedOption = 1
            setTextString('optA', '> Version A : Jouer l\'Adversaire <')
            setTextColor('optA', 'FFFF00')
            setTextString('optB', 'Version B : Normal (Boyfriend)')
            setTextColor('optB', 'FFFFFF')
        end
    end

    if keyJustPressed('accept') then
        playSound('confirmMenu')
        menuActive = false
        removeLuaSprite('bgMenu', true)
        removeLuaText('menuTitle', true)
        removeLuaText('optA', true)
        removeLuaText('optB', true)

        versionAChosen = (selectedOption == 1)
        playAsOpponent = versionAChosen

        if versionAChosen then
            setProperty('iconP1.flipX', 0)
            setProperty('iconP2.flipX', 0)
            setProperty('healthBar.flipX', 1)
            local unspawnLen = getProperty('unspawnNotes.length') - 1
            for i = 0, unspawnLen do
                local mustPress = getPropertyFromGroup('unspawnNotes', i, 'mustPress')
                setPropertyFromGroup('unspawnNotes', i, 'mustPress', not mustPress)
                setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
            end
        end

        startCountdown()
    end
end

function onStepHit()
    if versionAChosen and curStep == 255 then
        toggleOpponentMode(false)
    end
end

-- --- TOGGLE MODE ---
function toggleOpponentMode(enable)
    playAsOpponent = enable
    local duration = 0.4

    -- Tween des flèches
    for i = 0, 3 do
        local targetX = enable and defaultPlayerStrumX0 + (i*112) or defaultOpponentStrumX0 + (i*112)
        noteTweenX('dad'..i, i, targetX, duration, 'expoOut')
    end
    for i = 4, 7 do
        local targetX = enable and defaultOpponentStrumX0 + ((i-4)*112) or defaultPlayerStrumX0 + ((i-4)*112)
        noteTweenX('bf'..i, i, targetX, duration, 'expoOut')
    end

    -- Inversion des notes
    local notesLen = getProperty('notes.length') - 1
    for i = 0, notesLen do
        local must = getPropertyFromGroup('notes', i, 'mustPress')
        setPropertyFromGroup('notes', i, 'mustPress', not must)
        setPropertyFromGroup('notes', i, 'noAnimation', true)
    end
    local unspawnLen = getProperty('unspawnNotes.length') - 1
    for i = 0, unspawnLen do
        local must = getPropertyFromGroup('unspawnNotes', i, 'mustPress')
        setPropertyFromGroup('unspawnNotes', i, 'mustPress', not must)
        setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
    end

    -- Reset ou inversion de la healthbar
    if enable then
        setProperty('iconP1.flipX', 0)
        setProperty('iconP2.flipX', 0)
        setProperty('healthBar.flipX', 1)
    else
        setProperty('iconP1.flipX', 0)
        setProperty('iconP2.flipX', 0)
        setProperty('healthBar.flipX', 0)
    end
end

-- --- POSITION DES STRUMS AU START ---
function onSongStart()
    if playAsOpponent then
        for i = 0, 3 do setPropertyFromGroup('strumLineNotes', i, 'x', defaultPlayerStrumX0 + (i*112)) end
        for i = 4, 7 do setPropertyFromGroup('strumLineNotes', i, 'x', defaultOpponentStrumX0 + ((i-4)*112)) end
    end
end

-- --- HEALTHBAR INVERSÉE (Mode Adversaire seulement) ---
function onUpdatePost()
    if playAsOpponent then
        setProperty('iconP1.x', -593 + getProperty('healthBar.x') + (getProperty('healthBar.width') * (remapToRange(getProperty('healthBar.percent'), 0, -100, 100, 0) * 0.01)) + (150 * getProperty('iconP1.scale.x') - 150) / 2 - 26)
        setProperty('iconP2.x', -593 + getProperty('healthBar.x') + (getProperty('healthBar.width') * (remapToRange(getProperty('healthBar.percent'), 0, -100, 100, 0) * 0.01)) - (150 * getProperty('iconP2.scale.x')) / 2 - 26 * 2)
    end
end

function remapToRange(value, start1, stop1, start2, stop2)
    return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
end

-- --- GESTION DES CHANTS ---
function goodNoteHit(id, direction, noteType, isSustainNote)
    setPropertyFromGroup('notes', id, 'noAnimation', true)
    if playAsOpponent then
        characterPlayAnim('dad', getProperty('singAnimations['..direction..']'), true)
        setProperty('dad.holdTimer', 0)
    else
        characterPlayAnim('boyfriend', getProperty('singAnimations['..direction..']'), true)
        setProperty('boyfriend.holdTimer', 0)
    end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    setPropertyFromGroup('notes', id, 'noAnimation', true)
    if playAsOpponent then
        characterPlayAnim('boyfriend', getProperty('singAnimations['..direction..']'), true)
        setProperty('boyfriend.holdTimer', 0)
    else
        characterPlayAnim('dad', getProperty('singAnimations['..direction..']'), true)
        setProperty('dad.holdTimer', 0)
    end
end

function noteMiss(id, direction, noteType, isSustainNote)
    if playAsOpponent then
        local missAnim = getProperty('singAnimations['..direction..']') .. 'miss'
        characterPlayAnim('dad', missAnim, true)
        setProperty('dad.holdTimer', 0)
    end
end