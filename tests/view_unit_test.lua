package.path = package.path .. ";../?.lua"


expose("opa", function()
    
    describe("Verify if findComponentById is working as expected", function()
    
        it( "Should return nil if id is not a string", function()
            
            local view = require("view")
            local result = view:findComponentById(1)
            assert.is.falsy(result)
        end)
    
    end)

end)