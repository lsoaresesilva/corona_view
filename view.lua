--[[
    Change log 0.4

        - Added support for minimal validation on input fields.
        - Added support for styling textfield, box and button.
    
    Change log 0.3
        - One way binding
]]


--[[
    Recursos
        Componentes:
            * BlankSpace - puts a blank space on screen
            * Button
            * Text
            * Image
            * TextField
            * TextBox
        Controllers:
            * Associar listeners diretamente pelo XML
                - Eventos suportados: 
                    - Tap e Touch (qualquer componente)
                    - Userinput (textfield e box)
        CSS:
            * Suporte para CSS no componente de texto, textfield, textbox, button
        One-way binding
                
]]

--[[

    TODO: 
    
    * Tirar a obrigatoriedade do style (5)
    * Possibilitar recursos de validação (5)
    * Suporte para scroll (5)
    * Fazer um listener para os inputs. Ao alterar eles então deve ser pego o model e atualizar o seu valor (5)
        ** Permitir informar os atributos de uma class, por exemplo: pessoa.nome, quebrar a string considerando o . e atribuir ao controlador[primeira_parte_da_string][segunda_parte]
        ** Permitir a Convenção sobre configuração, será buscado no controlador o que for igual ao name do atributo
        ** Pode ser usado o padrão observer para implementar o two-way binding
    * Suporte para CSS (4)
        ** Parse CSS (1)
            - https://github.com/reworkcss/css/blob/master/lib/parse/index.js
        ** permitir carregar de qualquer arquivo
        ** permitir aplicar estilo a todos os componentes de um mesmo tipo
    * Suporte para lists (3)
    * Permitir o uso de variaveis lua no XML (3)
    * Permitir internacionalização (2)
        * Permitir a leitura das strings a partir de um outro arquivo XML
    * Implementar que o ID não possa ser repetido (2)
    * Ajustar a implementação de insert para funcionar como uma árvore (1)
    * Fazer custom components no estilo Android (1)
        * Diferentes tamanhos de texto
    
]]

local widget = require("widget")
local linearLayout = require("libs.linear_layout")

local t = {
    layoutsOnView = {},
    controller = nil
}

function joinTables(t1, t2)
    
    for k,v in pairs(t2) do
        
        t1[k] = v
    end
    
    return t1
end

function hasKey(table, key)

    for k,v in pairs(table) do
        if k == key then
            return true
        end
    end

    return false
end

function t:bindModel(component, properties)

    if self.controller ~=  nil then

        if properties.model ~= nil then
            
            if self.controller[properties.model] ~= nil then
                component:addEventListener("userInput", function(event)
                    
                    local target = event.target
                    if target.type == "textField" or target.type == "textBox" then
                            self.controller[properties.model] = target.text
                    end
                end)
            else
                error("The specified model: "..properties.model.." does not exists on controller")
            end
        end
    end
end

function t:applyListeners(component, properties)
    if self.controller ~=  nil then

        if properties.touch ~= nil then
            if self.controller[properties.touch] ~= nil and type(self.controller[properties.touch]) == "function" then
                
                if component.buttonType ~= nil then
                    component:addEventListener("touch", 
                    function(event) 
                        if event.phase == "ended" then
                            if self:doValidation() == true then
                                self.controller[properties.touch](event)
                            end
                        end
                    end)
                else
                    component:addEventListener("touch", self.controller[properties.touch])
                end
            else
                error("The specified function: "..properties.touch.." for listener does not exists on controller")
            end
        end

        if properties.tap ~= nil then
            if self.controller[properties.tap] ~= nil then
                component:addEventListener("tap", self.controller[properties.tap])
            else
                error("The specified function: "..properties.tap.." for listener does not exists on controller")
            end
        end

        if (component.type == "textField" or component.type == "textBox") and properties.userInput ~= nil then
            if self.controller[properties.userInput] ~= nil then
                component:addEventListener("userInput", self.controller[properties.userInput])
            else
                error("The specified function: "..properties.userInput.." for listener does not exists on controller")
            end
        end
    end
end

function t:applyCss(component, properties)
    if component.type == "text" or component.type == "textField" or component.type == "button" or component.type == "textBox" then
        pcall( function() 
            local css = require("style") 
    
            if type(css) == "table" then 
                local color = require("libs.convertcolor")

                if properties.class ~= nil then
                    if css[properties.class] ~= nil then
                            for k, v in pairs(css[properties.class]) do
                                if component.type == "text" or component.type == "button" then
                                    if k == "color" then
                                        component:setFillColor(color.hex(v))
                                    end
                                end

                                if component.type == "textField" or component.type == "textBox" then
                                    if k == "font" then
                                        local size = css[properties.class].size or 23
                                        component.font = native.newFont( v, size )
                                        component:resizeHeightToFitFont()
                                    elseif k == "align" then
                                        component.align = v
                                    end
                                end

                                if component.type == "text" or component.type == "textField" or component.type == "textBox" then
                                    if k == "size" then
                                        component.size = v
                                    end
                                end
                            end
                    end
                
                end
            end
        end)
         --unrequire( "style" )
    end
end

function t:applyValidation(component, properties)
    -- indicar que o campo será validado
    
    if properties.validation ~= nil then
        component.validation = {}
        -- indicar qual a validacao
        -- TODO: permitir mais uma validação. Seguir o padrão | | |  e quebrar a string nestes tokens. adicionar todos a tabela.
        table.insert(component.validation, properties.validation)
        
    end
    
end

function t:drawInvalidComponentsAlert(invalidComponents)
    
    local group = display.newGroup()
    for i=1, #invalidComponents do 
        local rects = display.newRect(invalidComponents[i].x-2, invalidComponents[i].y-2, invalidComponents[i].width+5, invalidComponents[i].height+5)
        rects.anchorX = 0
        rects.anchorY = 0
        rects:setFillColor(1,0,0)
        rects:setStrokeColor(1,0,0)
        group:insert(rects)
        -- TODO put in a group, use timer, show and hide
    end

    timer.performWithDelay(3000, function(event)
    
        for i=1, group.numChildren do
            
            if group[i] ~= nil then
                group[i]:removeSelf()
                group[i] = nil
            end
        
        end
        
        group:removeSelf()

    end)
    

    local toast = require("toast")
    local message
    message = "Required fields cannot be empty."
    local t = toast:new({text=message})
    t:show()
end

function t:doValidation()

    local components = self:getAllComponentsOnView()
    local invalidComponents = {}
    for i=1, #components do
    
        if components[i].type == "textField" or components[i].type == "textBox" then
            
            if  components[i].validation ~= nil then
                print(components[i].validation[1])
                for j=1, #components[i].validation do
                    if components[i].validation[j] == "required" then
                        print("validando...")
                        if components[i].text == "" then
                            table.insert(invalidComponents, components[i])
                        end
                    end
                end
            end
        end
    end

    self:drawInvalidComponentsAlert(invalidComponents)

    if #invalidComponents > 0 then
        return false
    end
   
   return true
end

-- An factory method used internally to create Corona Components.
-- You should not call this method directly.
function t:createFactory(tag, properties)

    -- Corona creates components using two forms: one passing a table in constructor and other passing parameters in constructor.
    -- In case where it receives parameters, we can set/get directly from component. eg. component.x . So, we just get the properties from XML (as a table) and concat with the component (as it is a table)
    local component
    if tag.name == "Text" then
        component = display.newText(properties)
        component.type = "text"
    elseif tag.name == "BlankSpace" then
        if not properties.width then
            error("BlankSpace tag must specifie a width attribute")
        end

        if not properties.height then
            error("BlankSpace tag must specifie a height attribute")
        end
        component = display.newRect(0, 0, properties.width, properties.height)
        component:setFillColor(0,0,0,0)
        component:setStrokeColor(0)
        component.type = "blankspace"
        
    elseif tag.name == "TextField" then
        
        component = native.newTextField(150, 150, 180, 30)
        component.type = "textField"
        joinTables(component, properties)
    elseif tag.name == "Image" then
        
        if not properties.filename then
            error("Image tag must specifie a filename attribute")
        end

        if not properties.width then
            error("Image tag must specifie a width attribute")
        end

        if not properties.height then
            error("Image tag must specifie a height attribute")
        end

        component = display.newImageRect(properties.filename, properties.width, properties.height) -- should verify if filename was passed on XML, if not throws error
        component.type = "image"
    elseif tag.name == "TextBox" then
        component = native.newTextBox(150, 150, 180, 50)
        component.type = "textBox"
        joinTables(component, properties)
    elseif tag.name == "Button" then
        properties["shape"] = "roundedRect"
        properties["fillColor"] = { default={1,0,0,1}, over={1,0.1,0.7,0.4} }
        properties["strokeColor"] = { default={1,0.4,0,1}, over={0.8,0.8,1,1} }
        properties["strokeWidth"] = 4
        component = widget.newButton(properties)
        component.type = "button"
        if hasKey(properties, "type") == true then
            component.buttonType = properties.type
        end
    elseif tag.name == "Slider" then
        component = widget.newSlider(properties)
        component.type = "slider"
    end

    

    self:applyCss(component, properties)
    self:applyListeners(component, properties)
    self:bindModel(component, properties)
    self:applyValidation(component, properties)

    return component
end



 
-- Creates a Corona Component from an specified XML TAG. Should not be called directly.
-- @param tag A Lua table which represents a XML TAG.
-- @return A Corona Component with all attributes specified on XML TAG.
function t:createComponentFromXML(tag)
    
    local properties = {}
    local componentId = nil
    for i = 1, #tag.attr do
        
        if tag.attr[i].name == "id" then
            componentId = tag.attr[i].value
        elseif tag.attr[i].name ~= "text" or 
               tag.attr[i].name ~= "label" or 
               tag.attr[i].name ~= "model" or
               tag.attr[i].name ~= "validation" then
            local numericValue = tonumber(tag.attr[i].value)
            if numericValue ~= nil then
                tag.attr[i].value = numericValue
            end
        
        end
        properties[tag.attr[i].name] = tag.attr[i].value
    end

    local component = self:createFactory(tag, properties)
    component.id = componentId



    if component ~= nil then
        return component
    end

  return component
end

-- Create all Corona Components specified on XML which belongs to a layout. Should not be called directly.
-- @param childs A table with XML TAG which belongs to a layout.
-- @return A table with all Corona Components after parse.
function t:extractComponentsAndSubLayouts(childs, rootLayout)
    local layoutChilds = {}
    --local layoutsFound = {}
    for j,element in ipairs(childs) do 
            
            if string.upper(element.name):find("LAYOUT") == nil then -- its a component, not layout
                local component = self:createComponentFromXML(element)
                if component ~= nil then
                    table.insert(layoutChilds, component)
                end
            
            else
                table.insert(element.attr, {name="parentLayout", value=rootLayout})
                element.type = "layout"
                table.insert(layoutChilds, element)
                
            end
    end

    return layoutChilds
end

-- Parses a Layout declared in XML and create all Corona Components on screen. Actually only LinearLayout is supported.
-- @param layout 
function t:extractLayout(layout)
    
    if layout.name == "LinearLayout" then
        
        local layoutId
        local attrLayout = {}
        for i=1, #layout.attr do

            if layout.attr[i].name == "id" then
                layoutId = layout.attr[i].value
            elseif layout.attr[i].name == "height" then
                attrLayout[layout.attr[i].name] = tonumber(layout.attr[i].value)
            else
                attrLayout[layout.attr[i].name] = layout.attr[i].value
            end
        end

        -- A layout must have an ID
        if not layoutId then
            return nil
        end
       
        local hlayout = linearLayout:new(attrLayout)
        hlayout.type = "layout"
        -- x,y do inner layout deverá ser a partir do que já tem na tela
        local childs = self:extractComponentsAndSubLayouts(layout.el, hlayout)
        
        self.layoutsOnView[layoutId] = hlayout
        
        for i=1, #childs do
            local childFound = childs[i]
            
            -- its a layout as it does not have a type already.
            -- we must extract its layout
            
            if childFound.type == "layout" then 
                local innerLayout = self:extractLayout(childFound)
                
                hlayout:insert(innerLayout, false)
            else
                if childFound.id ~= nil then
                    if self.controller ~= nil then
                        self.controller[childFound.id] = childFound
                    end
                end
                hlayout:insert(childFound, false)
            end
        end

        if hlayout.parentLayout == nil then -- only redraws when its finished with recursivity, and it is done when layout is a root element
            hlayout:draw()
        end
        --[[for i=1, #layoutsFound do
            
            
        end

        for i=1, #componentsFound do
            
        end]]

        return hlayout
    end
end

-- Parses the View declared as a XML and create all Corona Components declared on it.
-- XML root must be of LinearLayout, as it is the only supported layout at the moment.
-- Actually child elements can be from types:
function t:setView(xml, controller)
    
    self.controller = controller or nil

    local path = system.pathForFile(xml, system.ResourceDirectory)
    local hFile, err = io.open(path, "r");

    local SLAXML = require ('libs.slaxdom') -- also requires slaxml.lua; be sure to copy both files
    local myxml = hFile:read("*a"); -- read file content
    local doc = SLAXML:dom(myxml)

    local rootLayout
    for i,v in ipairs(doc.kids) do
        
        rootLayout = self:extractLayout(v)
    end

    return self
end

-- Retrieves a Layout by its specified id.
-- @param id String with layout's id
function t:findLayoutById(id)
    if type(id) == "string" then
        for i, v in pairs(self.layoutsOnView) do
            if i == id then
                return v
            end
        end
    end

    return nil
end

-- Retrieves a Component by its specified id.
-- @param id String with component's id
function t:findComponentById(id)

    if type(id) == "string" then
        for i, v in pairs(self.layoutsOnView) do
            local result = self.layoutsOnView[i]:findComponentById(id)

            if result ~= nil then
                return result
            end
        end
    end

    return nil
end

function t:getRootLayout()

    local stop = 1
    for i, v in pairs(self.layoutsOnView) do
        if stop == 1 then 
            return v
        end
    end
end

function t:getAllComponentsOnView()

    local rootLayout = self:getRootLayout()
    
    local components = rootLayout:getAllComponents({})
    
    return components

end


return t