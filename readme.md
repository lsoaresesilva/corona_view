# Corona SDK - View loader

CopyRight (C) 2017 - Leonardo Soares e Silva - lsoaresesilva@gmail.com

## Sumary

Creating user interfaces for busines apps on Corona can be hard task if you compare to Android's Activity Design, for example.
This library was inspired on Android and JavaFX user interface creation, and enables the creation of interfaces through XML files.

## Instalation

Just copy view.lua and linear_layout.lua to yout Corona project's folder.

## Usage

Example:

* Loading a view:

-- in your main.lua
local viewLoader = require("view")
local view = viewLoader:setView("layout.xml")

-- Create a file with .xml extension in your project's folder, example:

<LinearLayout id="layoutLinear" x="10" orientation="vertical" align="center" paddingX="10">
    <Text id="txtUsername" x="10" y="10" text="Username"  />
    <TextField />
    <Text id="txtPassword" x="10" y="50" text="Password" />
    <TextField />
    <Button label="Login" />
</LinearLayout>

And it is done.

![alt tag](http://i36.photobucket.com/albums/e43/leonardo_soares4/screenshot_xmllayout_zpshkhn0ix0.png)
