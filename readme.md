# Corona SDK - View loader

CopyRight (C) 2017 - Leonardo Soares e Silva - lsoaresesilva@gmail.com

## Sumary

Creating user interfaces for busines apps on Corona can be hard task if you compare to Android's Activity Design, for example.
This library was inspired on Android and JavaFX user interface creation, and enables the creation of interfaces through XML files.

## Instalation

Just copy view.lua, linear_layout.lua, slaxdom.lua and slaxml.lua to yout Corona project's folder.

## APIDoc

```lua

-- View functions

-- Defines the layout to be shown on screen and the controller to manage listeners.
-- @param layout : XML file within layout declaration
-- @param controller : A Lua table which contains functions used to proccess listeners events
-- @return : A Lua table within all elements extracted from layout.
setView(layout, controller)

local viewLoader = require("view")
local view = viewLoader:setView("layout.xml")

-- Searchs on view for the specified layout's id.
-- @param id : String which contains the layout's identifier we want to search.
-- @return : If a layout is found, returns it. If not returns nil.
findLayoutById(id)

-- Searchs on layouts for the specified components's id.
-- @param id : String which contains the component's identifier we want to search.
-- @return : If a component is found, returns it. If not returns nil.
findComponentById(id)

```

## Usage

Example:

* Loading a view:

```lua
-- in your main.lua
local viewLoader = require("view")
local view = viewLoader:setView("layout.xml")
```

-- Create a file with .xml extension in your project's folder, example:
```xml
<LinearLayout id="layoutLinear" orientation="vertical" align="center" paddingX="10">
    <Text id="txtUsername" x="10" y="10" text="Username"  />
    <TextField />
    <Text id="txtPassword" x="10" y="50" text="Password" />
    <TextField />
    <Button label="Login" />
</LinearLayout>
```
And it is done.

![alt tag](http://i36.photobucket.com/albums/e43/leonardo_soares4/screenshot_xmllayout_zpshkhn0ix0.png)

* Inserting components programmatically 

```lua
-- in your main.lua
local widget = require("widget")

local viewLoader = require("view")
local view = viewLoader:setView("layout.xml")
local layout = view:findLayoutById("layoutLinear")
local recoverButton = widget.newButton({label="Recover"})
layout:insert(recoverButton)
```

* Updating components programmatically 

```lua
-- in your main.lua
local widget = require("widget")

local viewLoader = require("view")
local view = viewLoader:setView("layout.xml")
local textUsername = view:findLayoutById("txtUsername")
textUsername.text = "New Text!"
```

* Use with composer

```lua
-- in your scene.lua

local composer = require("composer")
local viewLoader = require("view")
local view = viewLoader:setView("layout.xml")

local scene = composer.newScene()

function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    sceneGroup:insert(view)
end

return scene

```

* Inner layouts, BlankSpace, Image example and touch listener example:

```xml

<!-- An calculator example -->

<LinearLayout id="layoutLinear"  orientation="vertical" align="center">
    <TextField id="txtField"/>
    <BlankSpace width="10" height="20"/>
    <LinearLayout id="layoutFirstRow"  orientation="horizontal" align="center">
        <Image filename="btn_1.png" width="50" height="50" touch="pressButton"/>
        <Image filename="btn_2.png" width="50" height="50" />
        <Image filename="btn_3.png" width="50" height="50" />
        <Image filename="btn_sum.png" width="50" height="50" />
    </LinearLayout>
    <BlankSpace width="10" height="20"/>
    <LinearLayout id="layoutSecondRow"  orientation="horizontal" align="center">
        
        <Image filename="btn_4.png" width="50" height="50" />
        <Image filename="btn_5.png" width="50" height="50" />
        <Image filename="btn_6.png" width="50" height="50" />
        <Image filename="btn_minus.png" width="50" height="50" />
    </LinearLayout>
    
</LinearLayout>
```

## Changelog

* 0.2 - 15/03/2017

** Added support for nested/inner layouts;
** Added support for a css-like style (experimental);
** Added support for listeners definition through XML (works for tap, touch and userinput events);
** Added a two new components: Image and BlankSpace (inserts a blank space in yout layout);
** Refactored the function to position components on screen, its much better now :)