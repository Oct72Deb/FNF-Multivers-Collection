-- Place this in mods/YOUR_MOD/scripts/

local subtitles = {
    -- Format: {startTime, "Text", holdTime}
    {62.58, "These outfits sure are lovely.", 0.80, 19},
    {64.83, "True, I was half worried it was just going to be loads of foods and snacks.", 0.25, 29},
        {68.15, "Food and snacks are the best!", 0.20, 13},
        {70.05, "Anyway, here's the first house.", 0.05, 21},
        {72.0, "Oh ohhh ho, i know this house.", 0.31, 12},
        {75.43, "Why don't we give them a knock?", 0.30, 28},
        {79.18, "TRICK OR TREAT !", 0.30, 28},
        {80.04, "OH GOD, WHAT THE F*CK ! ", 0.30, 28},
        {81.64, "SCREAM! ", 0.37, 28},
        {120.57, "Now that's what I call a haul. ", 0.37, 28},
        {122.18, "We only visited one house, and yet we already have this much!", 0.36, 21},
        {126.04, "Next house!", 0.17, 20},
        {129.55, "TRICK OR TREAT !", 0.30, 28},
        {133.21, "Weeeeeel... ", 0.18, 20},
        {134.29, "Next house!", 0.10, 20},
        {138.1, "TRICK OR TREAT !", 0.30, 28},
}

local currentLineIndex = -1
local fullText = ''
local currentSubtitle = ''
local startTime = 0
local isLineComplete = false
local lineHoldTime = 2.0 -- default fallback if not specified

function onCreate()
    makeLuaText('subtitleText', '', 1280, 300, 510)
    setTextAlignment('subtitleText', 'left')
    setTextSize('subtitleText', 18)
    setTextFont('subtitleText', 'Aller_Bd.ttf')
    setObjectCamera('subtitleText', 'other')
    addLuaText('subtitleText')
    setTextBorder('subtitleText', 1, '000000')  
end

function onUpdatePost(elapsed)
    local songTime = getSongPosition() / 1000
    local subtitleShown = false

    for i, sub in ipairs(subtitles) do
        local subStart = sub[1]
        local subText = sub[2]
        local subHold = sub[3] or 2.0
        local subSpeed = sub[4] or 20
        local commaPause = 0.5

        -- Count how many commas up to a given character index
        local function getCommaCountUpTo(index)
            local partial = string.sub(subText, 1, index)
            local _, count = string.gsub(partial, ",", "")
            return count
        end

        -- Calculate how many letters should be shown based on adjusted time
        local rawElapsed = songTime - subStart
        local totalDelay = 0
        local realLetters = 0
        for j = 1, #subText do
            totalDelay = getCommaCountUpTo(j) * commaPause
            local adjustedTime = rawElapsed - totalDelay
            if adjustedTime >= j / subSpeed then
                realLetters = j
            else
                break
            end
        end

        local typeDuration = #subText / subSpeed + getCommaCountUpTo(#subText) * commaPause
        local subEnd = subStart + typeDuration + subHold

        if songTime >= subStart and songTime <= subEnd then
            if currentLineIndex ~= i then
                currentLineIndex = i
                fullText = subText
                currentSubtitle = ''
                startTime = subStart
                isLineComplete = false
            end

            if realLetters >= #fullText then
                realLetters = #fullText
                isLineComplete = true
            end

            local partialText = string.sub(fullText, 1, realLetters)
            if currentSubtitle ~= partialText then
                currentSubtitle = partialText
                setTextString('subtitleText', currentSubtitle)
            end

            subtitleShown = true
            break
        end
    end

    if not subtitleShown and currentLineIndex ~= -1 then
        currentLineIndex = -1
        currentSubtitle = ''
        setTextString('subtitleText', '')
    end
end