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
<LinearLayout id="layoutLinear" x="10" orientation="vertical" align="center" paddingX="10">
    <Text id="txtUsername" x="10" y="10" text="Username"  />
    <TextField />
    <Text id="txtPassword" x="10" y="50" text="Password" />
    <TextField />
    <Button label="Login" />
</LinearLayout>
```
And it is done.

![alt tag](http://url/to/img.png)

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