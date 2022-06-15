# ags-character-accessories

This module allows to add accessories to characters.
The accessories must be another characters.

It's similar than Character::FollowCharacter but with these improvements:
1. Accessories can be placed a zindex. The greater the zindex the closer to the camera the accessory get rendered
2. Accessories can have zoffset and xoffset to fine tune plament of items


## Usage
// cJoe is a Character that is being used as the player character
// cHat is a Character that portays a hat
// cGlasses is a Character that portrays a pair of glasses
// cSunGlasses is Character that portrays a pair of sunglasses
cJoe.CL_AddAccessory(cHat,1); // adds the hat to the player
cJoe.CL_AddAccessory(cGlasses,2); // adds the glasses to the player

// later
cJoe.CL_RemoveAccessory(cHat); // removes the hat from the player, but not from the screen.
cJoe.CL_SetAccessoryOffsetZ(cGlasses, 20); // the glasses will be drawn 20 pixeles above the natural Y position
cJoe.CL_AddAccessory(cSunGlasses, 2); // replaces the regular glasses by the sunglasses. The regular glasses are not removed from the screen. 
if (cJoe.CL_HasAccessory(cGlasses)) {
  cJoe.Say("I'm still wearing my glasses");
}

## Notices
1. By default the module allows to have 5 characters with accessories. If you need more, increase the constant MODULE_CL_ACCESSORIES_MAX_COUNT
2. By default, each character can have up to 5 accessories. If you need more, increase the constant MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER
 
