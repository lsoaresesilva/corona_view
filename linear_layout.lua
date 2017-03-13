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
]]

linear_layout = {}

function linear_layout:new(options)

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
    options.orientation = options.orientation or "horizontal"
    options.paddingX = options.paddingX or 0 -- used to space elements inside layout
    options.paddingY = options.paddingY or 0 -- used to space elements inside layout
    
    self.layout = display.newRect(options.x, options.y, options.width, options.height)
    self.layout.anchorX = 0.0
    self.layout.anchorY = 0.0
    self.layout:setFillColor(0,0,0)
    self.align = options.align
    self.paddingX = options.paddingX
    self.paddingY = options.paddingY
    self.components = display.newGroup()
    self.orientation = options.orientation
    return self
end

--[[
    Searchs on this layout for component with id.
]]
function linear_layout:findComponentById(id)

    if type(id) == "string" then
    
        for i=1, self.components.numChildren do
            if id == self.components[i].id then 
            
                return self.components[i]
            end
        end
    end

    return nil
end

function linear_layout:getIndexComponent(component) 

    if not component then
        error("Failed to get index. A component must be passed as parameter.")
    end

    local indexComponent = nil
    for i=1, self.components.numChildren do
        if component == self.components[i] then 
            indexComponent = i
            break
        end
    end

    return indexComponent
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


function linear_layout:updateComponentsPosition()
    if self.components.numChildren > 0 then -- only update if there is atleast one component
        if self.components.numChildren > 1 then -- more than one component all update will be cascated based on the first one
            local firstComponent = self.components[1]

            -- If horizontal, should it shrink elements as Android and JavaFX does?
            if( self.orientation == "horizontal") then
               
                if self.align == "center" then
                    
                    local larguraTodosComponentes = 0
                    for i=1, self.components.numChildren do
                            larguraTodosComponentes = larguraTodosComponentes+self.components[i].width
                            
                            -- acrescentar o padding dos elementos = nElementos*tamanhoPadding
                    end

                    local espacoTela = (display.contentWidth-larguraTodosComponentes)*0.5
                    
                    for i=1, self.components.numChildren do
                            
                            if i==1 then
                                firstComponent.x = espacoTela
                            else
                                local lastComponentUpdated = self.components[i-1]
                                self.components[i].x = lastComponentUpdated.x+lastComponentUpdated.width+self.paddingX
                                self.components[i].y = firstComponent.y+self.paddingY
                            end
                    end
                    
                else
                    for i=2, self.components.numChildren do
                        self.components[i].x = firstComponent.x+firstComponent.width+self.paddingX
                        self.components[i].y = firstComponent.y+self.paddingY
                    end
                end
                    
            elseif( self.orientation == "vertical") then
                
                if self.align == "center" then
                    --centralizar os componentes considerando o seu centro (centerX e center Y)
                    local alturaTodosComponentes = 0
                    
                    for i=1, self.components.numChildren do
                            
                            alturaTodosComponentes = alturaTodosComponentes+self.components[i].height
                            
                            -- acrescentar o padding dos elementos = nElementos*tamanhoPadding
                    end

                    local espacoTela = (display.contentHeight-alturaTodosComponentes)*0.5

                    for i=1, self.components.numChildren do
                            
                            if i==1 then
                                firstComponent.y = espacoTela
                            else
                                local lastComponentUpdated = self.components[i-1]
                                self.components[i].y = lastComponentUpdated.y+lastComponentUpdated.height+self.paddingY
                            end
                            
                            local espacoTelaEixoX = (display.contentWidth-self.components[i].width)*0.5
                            self.components[i].x = espacoTelaEixoX
                    end
                else
                    
                    for i=2, self.components.numChildren do
                        self.components[i].y = firstComponent.x+firstComponent.height+self.paddingY
                        self.components[i].x = firstComponent.x+self.paddingX
                    end
    
                end
                
                
            end
        else
            local component = self.components[self.components.numChildren]
            if self.orientation == "vertical" then
                if self.align == "left" then 
                    component.x = self.layout.x+self.paddingX
                    component.y = self.layout.y+self.paddingY
                    
                elseif self.align == "center" then
                    local espacoTelaEixoX = (display.contentWidth-component.width)*0.5
                    component.x = espacoTelaEixoX
                    --component.x = display.contentWidth*0.5-component.width*0.5+self.paddingX
                    component.y = display.contentHeight*0.5+self.paddingX
                end
            elseif self.orientation == "horizontal" then
                if self.align == "left" then
                    component.x = self.layout.x+self.paddingX
                    component.y = self.layout.y+self.paddingY
                    
                elseif self.align == "center" then
                    component.x = display.contentWidth*0.5-component.width*0.5+self.paddingX
                    component.y = display.contentHeight*0.5+self.paddingY
                    
                end
            end
            
        end 
    end
end

function linear_layout:insert(component)
    -- A component cannot be added twice
    local componentAlreadyAdded = self:getIndexComponent(component)
    
    if not componentAlreadyAdded then
        component.parentLayout = self
        component.anchorX = 0.0
        component.anchorY = 0.0
        
        self.components:insert(component)
        self:updateComponentsPosition()
    end
end

function linear_layout:translate(deltaX, deltaY)
    self.components:translate(deltaX, deltaY)
end

function linear_layout:remove(component)
    local indexComponent = self:getIndexComponent(component)
    if indexComponent then
        if self.components.numChildren > 0 then
            self.components:remove(indexComponent)
            --[[local posXNext = self.components[indexComponent].x
            local posYNext = self.components[indexComponent].y
            local posXOld
            local posYOld
            self.components:remove(indexComponent)
            if( indexComponent == self.components.numChildren) then
                self.components[self.components.numChildren].x = posXNext
                self.components[self.components.numChildren].y = posYNext
            else
                for i = indexComponent, self.components.numChildren do
                    posXOld = self.components[i].x
                    posYOld = self.components[i].y
                    self.components[i].x = posXNext
                    self.components[i].y = posYNext
                    posXNext = posXOld
                    posYNext = posYOld
                end
            end
            
        else
            self.components:remove(component)
        end]]

            self:updateComponentsPosition()
        end
    end
end

return linear_layout