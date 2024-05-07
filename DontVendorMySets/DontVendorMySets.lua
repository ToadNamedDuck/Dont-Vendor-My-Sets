local frame = CreateFrame("FRAME", "DontVendorMySets");
local DVMS_Active = false;
local rightClickedLastEvent = false;
local itemData = nil;
local savedItem = nil;
frame:RegisterEvent("MERCHANT_SHOW");
frame:RegisterEvent("MERCHANT_CLOSED");
frame:RegisterEvent("ITEM_LOCKED");
frame:RegisterEvent("GLOBAL_MOUSE_DOWN");
StaticPopupDialogs["DVMS_ConfirmSetSell"] = {
   text = "Do you really want to sell %s - which is part of your %s Set(s)?",
   button1 = "Yes",
   button2 = "No",
   OnCancel = function()
      --Need to loop through the 12 slots to see if the item matches the item id
      for  i=1,12 do
         if C_MerchantFrame.GetBuybackItemID(i) == savedItem.id
         then BuybackItem(i)
         end
      end
   end,
   timeout = 0,
   whileDead = true,
   hideOnEscape = true,
   preferredIndex = 3,
}
--need a function that is callable once it is established that the window is open
local function merchantOpenEventHandler(passedEvent, ...)
   if(passedEvent == "MERCHANT_CLOSED") then DVMS_Active = false;
   end
   if(passedEvent == "GLOBAL_MOUSE_DOWN" and ... == "RightButton")
   then rightClickedLastEvent = true; end
   if(passedEvent == "GLOBAL_MOUSE_DOWN" and ... ~= "RightButton")
   then rightClickedLastEvent = false; end
   if(passedEvent == "ITEM_LOCKED" and rightClickedLastEvent == true)
   then 
      rightClickedLastEvent = false;
      local info = {...};
      local bag = info[1];
      local slot = info[2];
      itemData = C_TooltipInfo.GetBagItem(bag, slot);
      local itemName = itemData.lines[1].leftText;
      local itemIsInSet = false;
      local itemSetName = nil;--need to chop off the equipment sets: in the str if found
      for key, value in pairs(itemData["lines"]) do
         if(string.find(value["leftText"], "Equipment Sets: "))
         then itemIsInSet = true
            itemSetName = string.sub(value["leftText"],17,-1)
            savedItem = C_TooltipInfo.GetBagItem(bag, slot);
            PlaySound(9379);
            StaticPopup_Show ("DVMS_ConfirmSetSell", itemName, itemSetName);
         end
      end
   end
end
local function eventHandler(self, event, ...)
   --Make sure that the vendor frame is open before doing anything
   if(DVMS_Active == true) then merchantOpenEventHandler(event, ...);
   else--Merch window closed
      if (event == "MERCHANT_SHOW") then DVMS_Active = true;
         merchantOpenEventHandler(event, ...);
      end
   end
end
frame:SetScript("OnEvent", eventHandler);