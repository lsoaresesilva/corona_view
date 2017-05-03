--[[
    Recursos:

    - Posicionamentos vertical e horizontal
    - Alinhamento central e a esquerda
    - Padding x e y

]]

--[[ ROADMAP

* Permitir adicionar um padding interno para cada elemento (1)
* Fazer com que um item não possa passar o tamanho do layout (3)
    * Shrink elements if the width is > than layout's size
* Nested layouts (4)
* Add a default padding as Android

]]

linear_layout = {}
linear_layout_mt = { __index = linear_layout }

function linear_layout:new(options)
    
    layoutObject = {}
    --layoutObject.__index = linear_layout
    options = options or {}
    
    
    options.x = options.x or 0
    if type(options.x) ~= "number" then
        error("x must be a number")
    end

    options.y = options.y or 0
    if type(options.y) ~= "number" then
        error("y must be a number")
    end

    options.width = options.width or display.contentWidth
    options.height = options.height or display.contentHeight
    options.align = options.align or "center"
    options.parentLayout = options.parentLayout or nil
    options.orientation = options.orientation or "horizontal"
    options.paddingX = options.paddingX or 10 -- used to space elements inside layout
    options.paddingY = options.paddingY or 10 -- used to space elements inside layout

    layoutObject.layout = display.newRect(options.x, options.y, options.width, options.height)
    layoutObject.layout.isVisible = false -- change on production
    layoutObject.layout.anchorX = 0.0
    layoutObject.layout.anchorY = 0.0
    layoutObject.layout:setFillColor(0,0,0)
    layoutObject.align = options.align
    layoutObject.paddingX = options.paddingX
    layoutObject.paddingY = options.paddingY
    layoutObject.childs = {}
    layoutObject.orientation = options.orientation
    layoutObject.parentLayout = options.parentLayout
    layoutObject.id = options.id
    layoutObject.innerLayouts = {}
    
    local object = setmetatable(layoutObject, linear_layout_mt)
    
    return object
end

--[[
    Searchs on this layout for component with id.
]]
function linear_layout:findComponentById(id)

    if type(id) == "string" then
    
        for i=1, #self.childs do
            if id == self.childs[i].id then 
            
                return self.childs[i]
            end
        end
    end

    return nil
end

function linear_layout:getIndexElement(element) 
    
    if not element then
        error("Failed to get index. A element must be passed as parameter.")
    end

    local indexElement = nil
    for i=1, #self.childs do
        if element == self.childs[i] then 
            indexElement = i
            break
        end
    end

    return indexElement
end



--[[
function linear_layout:verifyValidId(component)
   
    if not component.id then
        
        error("You did not informed an id for your component")
    end

    if self:findComponentById(component.id) == nil then
        error("You have passed two components within same id. Ids must be unique.")
    end

    return true
end]]

function linear_layout:sumWidthOfAllComponents()

    local widthOfComponents = 0
    for i=1, #self.childs do
        if self.childs[i].type ~= "layout" then
            widthOfComponents = widthOfComponents+self.childs[i].width
            -- acrescentar o padding dos elementos = nElementos*tamanhoPadding
        end
    end
    return widthOfComponents
end

function linear_layout:sumHeightOfAllComponents()

    local heightOfComponents = 0
    for i=1, #self.childs do
        if self.childs[i].type ~= "layout" then                            
            heightOfComponents = heightOfComponents+self.childs[i].height
        -- acrescentar o padding dos elementos = nElementos*tamanhoPadding
        end
    end
    return heightOfComponents
end

function linear_layout:getRootLayout()

    local layout
    if self.parentLayout == nil  then
        layout = self
        return layout
    else
        layout = self.parentLayout:getRootLayout()
    end

    return layout
end



function linear_layout:draw()
    print("desenhando")
    local rootLayout = self:getRootLayout()
    local height, width = rootLayout:getDimensionsFromComponents()
    
    local componentReference = rootLayout.childs[1]
    
    rootLayout:updtComponentsPositions(height, width, 1, componentReference)
    
end

-- a pos Y do elemento n+1 será a pos Y do elemento n+sua altura

function linear_layout:pvtPos(totaComponentslHeightOnScreen, totalWidthComponentsOnScreen, level, component, componentReference)
    
        --print(component.id)
        -- ENTRAR RECURSIVAMENTE EM CADA COMPONENTE E RENDERIZAR
        -- posiciona o primeiro elemento
            -- Pega a largura e altura dos componentes
                
            -- verifica se for vertical

            
    --if self.align == "center" then
        -- verifica se o componente pertence a  um layout que está dentro de outro
        local actualWidthSize = self:sumWidthOfAllComponents()+#self.childs*self.paddingX
        if self.parentLayout ~= nil then
            
            local rootLayout = self:getRootLayout() -- TODO: passar por parâmetro
            local posX
            local posY     
            if self.orientation == "horizontal" then
                -- se for o primeiro elemento do layout e o rootlayout for center
                if rootLayout.align == "center" and level == 1 then
                    posY = componentReference.y + componentReference.height
                else
                    posY = componentReference.y
                end
                
                if level > 1 then
                    posX = componentReference.x+componentReference.width + self.paddingX
                else
                    posX = (display.contentWidth-actualWidthSize)*0.5
                end
            else
                posY = componentReference.y + componentReference.height
                posX = (display.contentWidth-component.width)*0.5
            end

            component.x = posX
            component.y = posY
        else -- there is no parentLayout, so it is the rootLayout
            local posY
            local posX
           
            if self.orientation == "vertical" then
                if self.align == "center" then
                    posX = (display.contentWidth-component.width)*0.5
                    posY = (display.contentHeight-totaComponentslHeightOnScreen)*0.5
                else
                    posX = 0
                    posY = 0
                end
                
                if level > 1 then
                    posY = componentReference.y+componentReference.height
                end
            else -- orientação horizontal
                if self.align == "center" then
                    posX = (display.contentWidth-totalWidthComponentsOnScreen)*0.5
                    posY = (display.contentHeight-component.height)*0.5
                else
                    posX = 0
                    posY = 0
                end

                if level > 1 then
                    posX = componentReference.x+componentReference.width
                end
                
                --component.x = (display.contentWidth-totalWidthComponentsOnScreen)*0.5
                --component.y = (display.contentHeight-component.height)*0.5
            end
            component.y = posY
            component.x = posX
        end
    --end -- end align

    return component
end
-- @param level used to know in which hierarchy this layout is from its parentLayout
function linear_layout:updtComponentsPositions(totaComponentslHeightOnScreen, totalWidthComponentsOnScreen, level, componentReference)
    
    local childsSize = #self.childs
    if childsSize > 0 then -- only update if there is atleast one component
        
        -- PROBLEMA:
        -- * Se usar um layout vertical e coloca um txt, um layout e dps uma image, este último elemento é inserido após o primeiro elemento do layout (txt). não se considera a ordem, com o innerlayout
        for i=1, #self.childs do
            local element = self.childs[i]
            
            if element.type == "layout" then
                
                componentReference = element:updtComponentsPositions(totaComponentslHeightOnScreen, totalWidthComponentsOnScreen, i, componentReference)
            else
                componentReference = self:pvtPos(totaComponentslHeightOnScreen, totalWidthComponentsOnScreen, i, element, componentReference)
            end
        end

        --[[if( #self.innerLayouts > 0 ) then
            
            for i=1, #self.innerLayouts do
                componentReference = self.innerLayouts[i]:updtComponentsPositions(totaComponentslHeightOnScreen, totalWidthComponentsOnScreen, i, componentReference)
            end
            
        end]]
                -- verifica se for center


            -- se não tiver innerLayout, o primeiro é posicionado como antes
            -- se tiver parentLayout
                
        -- os demais serão posicionados a partir dele
    end

    return componentReference
end

function linear_layout:getDimensionsFromComponents()
    
    local heightOfComponents = 0
    local widthOfComponents = 0
    
    for i=1, #self.childs do
                            
        if self.childs[i].type ~= "layout" then
            
            -- APENAS DEVE SOMAR heightOfComponents SE a orientação for vertical
            if self.orientation == "vertical" or i == 1 then
                heightOfComponents = heightOfComponents+self.childs[i].height 
            end

            if self.orientation == "horizontal" or i == 1 then
            -- APENAS DEVE SOMAR width SE a orientação for horizontal
                widthOfComponents = widthOfComponents+self.childs[i].width
            end
            -- acrescentar o padding dos elementos = nElementos*tamanhoPadding
        else
            
        end

    end
    
    if( #self.innerLayouts > 0 ) then
        
        for i=1, #self.innerLayouts do
            heightOfComponents = heightOfComponents + self.innerLayouts[i]:getDimensionsFromComponents()
            widthOfComponents = widthOfComponents+self.innerLayouts[i]:getDimensionsFromComponents()
        end
        
    end

    return heightOfComponents, widthOfComponents
end

function linear_layout:sumHeightOfAllComponents()

    if self.parentLayout == nil  then
        local heightOfComponents = 0
        for i=1, #self.childs do
                                
            heightOfComponents = heightOfComponents+self.childs[i].height
            -- acrescentar o padding dos elementos = nElementos*tamanhoPadding
        end

        --descer na árvore
        if( #self.innerLayouts > 0 ) then

            heightOfComponents = heightOfComponents + self.parentLayout:sumHeightOfAllComponents()
        end
    else    
            self.parentLayout:sumHeightOfAllComponents()
        
    
    end

    return heightOfComponents
end

-- @param draw diz ao layout para ele ser desenhado novamente. por padrão true, use falso apenas quando for iterar sobre um conjunto de elementos que serão adicionados e desejar desenhar apenas ao término da operação
function linear_layout:insert(element, draw)
    
    if( draw == nil ) then
        draw = true
    end

    local elementAlreadyAdded = self:getIndexElement(element)
    
    if not elementAlreadyAdded then
        
        if element.type == "layout" then -- a layout can be a child of other layouts and also can have innerlayouts
            table.insert(self.innerLayouts, layout)
            table.insert(self.childs, element)
        else
            element.parentLayout = self
            element.anchorX = 0.0
            element.anchorY = 0.0
            table.insert(self.childs, element)
            if draw == true then
                self:draw()
            end
        end
        
    end
    
end

function linear_layout:remove(component)
    local indexComponent = self:getIndexElement(component)
    if indexComponent then
        if #self.childs > 0 then
            table.remove(indexComponent)
            self:updateComponentsPosition()
        end
    end
end

-- TODO mudar, pois o último elemento pode ser do tipo layout e se for, deve descer recursivamente nele e ir até o último elemento de fato.
function linear_layout:findLastComponent()
    if #self.childs > 0 then
        return self.childs[#self.childs]
    else
        return nil
    end
end

function linear_layout:findLastInnerLayout()
    
    if #self.innerLayouts > 0 then
        return self.innerLayouts[#self.innerLayouts]
    else
        return nil
    end
end

return linear_layout