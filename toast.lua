--[[

    TODO:

    
    ** Permitir colocar um texto dentro deste retângulo
    ** Adicionar quebra de linha se o texto for maior que o retângulo
    ** Colocar um temporizador para desaparecer o retângulo

    FEITO:

    ** Exibir um retângulo semitransparente

]]

toast = {

}

function toast:new(options)
    local object = {}
    setmetatable(object, {__index = toast})
    options = options or {}
    options.text = options.text or ""

    object.options = options

    return object
end

function toast:show()
    if self.options.text ~= "" then
        -- TODO: do not recreate, just change options and show and hide
        local group = display.newGroup()
        local text = display.newText({text=self.options.text})
        group:insert(text)
        
        local rect = display.newRoundedRect(display.contentWidth*0.5, display.contentHeight-30, text.width*2, 30, 12)
        rect:setFillColor(0,0,0, 0.6)
        group:insert(rect)

        text.x = rect.x
        text.y = rect.y
        text:toFront()

        timer.performWithDelay( 3000, 
        function(event)
            text:removeSelf()
            text = nil
            rect:removeSelf()
            rect = nil
        end )
    end
end

return toast