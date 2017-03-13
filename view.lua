--[[
    
    * Implementar o tipo TextBox
    * Implementar que o ID não possa ser repetido (2)
    * Permitir incluir um elemento programaticamente ao layout
    * Permitir remover um elemento programaticamente do layout (5)
    * Permitir definir uma cor direto no layout
    * retornar algo para ser usado no composer
    ** Implementar nested layouts
]]

local widget = require("widget")
local linearLayout = require("linear_layout")

local t = {
    layoutsOnView = {}
}

function joinTables(t1, t2)
    
    for k,v in pairs(t2) do
        
        t1[k] = v
    end
    
    return t1
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
    elseif tag.name == "TextField" then
        
        component = native.newTextField(150, 150, 180, 30)
        component.type = "textField"
        joinTables(component, properties)
        
    elseif tag.name == "TextBox" then
        component = native.newTextBox(150, 150, 180, 30)
        component.type = "textBox"
        joinTables(component, properties)
    elseif tag.name == "Button" then
        properties["shape"] = "roundedRect"
        properties["fillColor"] = { default={1,0,0,1}, over={1,0.1,0.7,0.4} }
        properties["strokeColor"] = { default={1,0.4,0,1}, over={0.8,0.8,1,1} }
        properties["strokeWidth"] = 4
        component = widget.newButton(properties)
        component.type = "button"
    elseif tag.name == "Slider" then
        component = widget.newSlider(properties)
        component.type = "slider"
    end

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
        elseif tag.attr[i].name ~= "text" or tag.attr[i].name ~= "label" then
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
function t:extractComponents(childs)
    local componentsFound = {}
    for j,m in ipairs(childs) do 
            
            local component = self:createComponentFromXML(m)
            if component ~= nil then
                table.insert(componentsFound, component)
            end
    end

    return componentsFound
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
            end
        
            if layout.attr[i].name == "x" or layout.attr[i].name == "y" or layout.attr[i].name == "height" then
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
        local componentsFound = 
        self:extractComponents(layout.el)
        self.layoutsOnView[layoutId] = hlayout
        for i=1, #componentsFound do
            hlayout:insert(componentsFound[i])
        end

        return hlayout
    end
end

-- Parses the View declared as a XML and create all Corona Components declared on it.
-- XML root must be of LinearLayout, as it is the only supported layout at the moment.
-- Actually child elements can be from types:
function t:setView(xml)

    local path = system.pathForFile(xml, system.ResourceDirectory)
    local hFile, err = io.open(path, "r");

    local SLAXML = require 'slaxdom' -- also requires slaxml.lua; be sure to copy both files
    local myxml = hFile:read("*a"); -- read file content
    self.doc = SLAXML:dom(myxml)

    local rootLayout
    for i,v in ipairs(self.doc.kids) do
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
return t