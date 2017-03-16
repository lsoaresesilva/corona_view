# Corona SDK - View loader

CopyRight (C) 2017 - Leonardo Soares e Silva - lsoaresesilva@gmail.com

## Sumary

Creating user interfaces for busines apps on Corona can be hard task if you compare to Android's Activity Design, for example.
This library was inspired on Android and JavaFX user interface creation, and enables the creation of interfaces through XML files.

## Instalation

Just copy view.lua, linear_layout.lua, slaxdom.lua and slaxml.lua to yout Corona project's folder.

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

## Changelog

* 0.2 - 15/03/2017

** Added support for nested/inner layouts;
** Added support for a css-like style (experimental);
** Added support for listeners definition through XML (works for tap, touch and userinput events);
** Added a two new components: Image and BlankSpace (inserts a blank space in yout layout);
** Refactored the function to position components on screen, its much better now :)