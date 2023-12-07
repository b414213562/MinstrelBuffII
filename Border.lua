import "Turbine.UI";

-- Implementation based on Exogenesis9's code in 
-- The Lord of the Rings Discord, #add-ons channel

Border = class(Turbine.UI.Control);

function Border:Constructor(parent, thickness, color)
    Turbine.UI.Control.Constructor(self);

    self:SetParent(parent);
    self:SetBackColor(color);
    self:SetPosition(-thickness, -thickness);
    self:SetSize(
        parent:GetWidth() + thickness * 2, 
        parent:GetHeight() + thickness * 2);
    self:SetMouseVisible(false);

    self.cutout = Turbine.UI.Control();
    self.cutout:SetParent(self);
    self.cutout:SetBackColor(Turbine.UI.Color(0,0,0,0))
    self.cutout:SetSize(parent:GetSize());
    self.cutout:SetPosition(thickness, thickness);
    self.cutout:SetMouseVisible(false);

    self:SetStretchMode(1);
end

function Border:Detach()
    self:SetParent(nil);
    self:SetVisible(false);
end
