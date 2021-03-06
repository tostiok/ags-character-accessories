AGSScriptModule        ?)  int newID = 0;
CL_CharacterAccessories* accessories[MODULE_CL_ACCESSORIES_MAX_COUNT];
int owners[];
int characterIsAccessoryOf[];
int accessoryType[];

function ResetAccessoriesArray(CL_CharacterAccessories* ca){
  for (int i = 0; i < MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER ; i++) {
    ca.accessories[i] = EMPTY_CHARACTER_INDEX;
    ca.zIndexes[i] = EMPTY_ZINDEX;
    ca.offsetZ[i] = 0;
    ca.offsetX[i] = 0;
  }
  ca.accessoriesCount = 0;
}

function RemoveAccessoryAtIndex(CL_CharacterAccessories* ca,  int i) {
  characterIsAccessoryOf[ca.accessories[i]] = EMPTY_CHARACTER_INDEX;
  ca.accessories[i] = EMPTY_CHARACTER_INDEX;
  ca.zIndexes[i] = EMPTY_ZINDEX;
  ca.offsetZ[i] = 0;
  ca.offsetX[i] = 0;
}


String IntArrayToString(int arr[],  int count) {
  String output = "";
  for (int i = 0; i < count ; i++) {
    if (i > 0) {
      output = output.Append(", ");
    }
    output = output.Append(String.Format("%d", arr[i]));
  }
  return output;
}

int[] GetAccessories(CL_CharacterAccessories* ca) {
  int res[];
  res = new int[MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER];
  for (int i = 0; i < MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER ; i++) {
    res[i] = ca.accessories[i];
  }
  return res;
}

int[] GetZindexes(CL_CharacterAccessories* ca) {
  int res[];
  res = new int[MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER];
  for (int i = 0; i < MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER ; i++) {
    res[i] = ca.zIndexes[i];
  }
  return res;
}



static CL_CharacterAccessories* CL_CharacterAccessories::Create(Character* c) {
  CL_CharacterAccessories* ca = new CL_CharacterAccessories;
  ca.ID = newID;
  
  accessories[ca.ID] = ca;
  owners[c.ID] = ca.ID;
  ca.ownerCharacterID = c.ID;
  ResetAccessoriesArray(ca);
  
  newID++;
  return ca;
}

function IsCharacterOwner(Character* c) {
  return owners[c.ID] != EMPTY_CHARACTER_INDEX;
}

CL_CharacterAccessories* GetCharacterAccessories(Character* c) {
  if (!IsCharacterOwner(c)) return null;
  return accessories[owners[c.ID]];
}

Character* CL_CharacterAccessories::GetOwner() {
  return character[this.ownerCharacterID];
}

function CL_CharacterAccessories::RenderAccessory(int i) {
  Character* accessory = character[this.accessories[i]];
  Character* owner = this.GetOwner();
  int offsetX = this.offsetX[i];
  if (owner.Loop == 1) { // left
    
  }
  if (owner.Loop == 2) { // right
    offsetX = -offsetX;
  }
  accessory.x = owner.x + offsetX * owner.Scaling / 100;
  accessory.y = owner.y;
  accessory.z = owner.z + this.offsetZ[i];
  accessory.Loop = owner.Loop;
  accessory.Frame = owner.Frame;
  accessory.on = owner.on;
  //accessory.Scaling = cOwner.Scaling;
  //accessory.ManualScaling = true;
  int baseLine = owner.y + this.zIndexes[i] + 1;
  accessory.Baseline = baseLine;
}

function CL_CharacterAccessories::Render() 
{
  Character* owner = this.GetOwner();
  if (owner.Room != player.Room) return;
  for (int x = 0; x < this.accessoriesCount ; x++) {
    this.RenderAccessory(x);
  }  
}

bool CL_CharacterAccessories::Has(Character* accesory) {
  for (int i = 0; i < this.accessoriesCount ; i++) {
    if (this.accessories[i] == accesory.ID) return true;
  }
  return false;
}


protected function CL_CharacterAccessories::SwapAccessories(int indexA, int indexB) {
  int tmp = this.accessories[indexA];
  this.accessories[indexA] = this.accessories[indexB];
  this.accessories[indexB] = tmp;
  
  tmp = this.zIndexes[indexA];
  this.zIndexes[indexA] = this.zIndexes[indexB];
  this.zIndexes[indexB] = tmp;          
  
  tmp = this.offsetZ[indexA];
  this.offsetZ[indexA] = this.offsetZ[indexB];
  this.offsetZ[indexB] = tmp;          
}

function CL_CharacterAccessories::Compact() {
  int a = 0;
  int b = 0;
  this.accessoriesCount = 0;
  for (b = 1 ; b < MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER ; b++) {
    if (this.accessories[a] == EMPTY_CHARACTER_INDEX) {
      this.SwapAccessories(a,  b);
    }
    if (this.accessories[a] != EMPTY_CHARACTER_INDEX) {
      a++;
      this.accessoriesCount++;
    }
  }
}

int CL_CharacterAccessories::GetZindexAtIndex(int index) {
  return this.zIndexes[index];
}

int CL_CharacterAccessories::MakeRoomForZIndex(int zindex)
{
  if (this.zIndexes[MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER-1] != EMPTY_ZINDEX) {
    if (this.zIndexes[MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER-1] < zindex) {
      return -1;
    }
  }
  
  for (int i = MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER  - 1 ; i >= 0 ; i--) {
    if (i == 0) {
      if (this.zIndexes[i] == EMPTY_ZINDEX) {
        return i;
      } else {
        return -1;
      }
    }
    
    if (this.zIndexes[i-1] != EMPTY_ZINDEX) {
      if (this.zIndexes[i-1] == zindex) {
        RemoveAccessoryAtIndex(this,  i-1);
      }
      if (this.zIndexes[i-1] <= zindex) {
        return i;
      } else {
        this.SwapAccessories(i-1, i);
      }
    }
  }
    
  return -1;
}

function RemoveAccessory(CL_CharacterAccessories* ca,  Character* accessory) {
  for (int i = 0; i < ca.accessoriesCount ; i++) {
    if (ca.accessories[i] == accessory.ID) {
      RemoveAccessoryAtIndex(ca,  i);
    }
  }
}

function CL_CharacterAccessories::Remove(Character* accessory) {
  RemoveAccessory(this,  accessory);
  this.Compact();
}

protected function CL_CharacterAccessories::Set(Character* accessory,  int position,  int zindex,  int type) {
  int currentOwner = characterIsAccessoryOf[accessory.ID];
  if (currentOwner != EMPTY_CHARACTER_INDEX) {
    //CL_Console.Log(String.Format("El accesorio %d ya pertenece al character %d", accessory.ID,  currentOwner));
    if (currentOwner != this.ownerCharacterID) {
      CL_CharacterAccessories* ca = GetCharacterAccessories(character[currentOwner]);
      ca.Remove(accessory);
    }
    else {
      RemoveAccessory(this,  accessory);
    }
  }
  
  this.accessories[position] = accessory.ID;
  this.zIndexes[position] = zindex;
  characterIsAccessoryOf[accessory.ID] = this.ownerCharacterID;
  accessoryType[accessory.ID] = type;

  Character* owner = character[this.ownerCharacterID];
  accessory.ChangeRoom(owner.Room);
  this.Compact();
  
  //CL_Console.Log(String.Format("----[Set ID: %d, at position %d, zIndex: %d", accessory.ID,  position,  zindex));
  //CL_Console.Log(String.Format("accessories: %s | zindexes: %d| %d", 
  //  IntArrayToString(GetAccessories(this), this.accessoriesCount),
  //  IntArrayToString(GetZindexes(this), this.accessoriesCount),
   // this.accessoriesCount)
  //  );
  this.RenderAccessory(position);  
}


function GetAccessoryType(int characterID) {
  return accessoryType[characterID];
}

function GetFirstTypePosition(CL_CharacterAccessories* ca,  int type) {
  int result = ca.accessoriesCount;
  for (int i = 0; i < ca.accessoriesCount ; i++) {
    if (GetAccessoryType(ca.accessories[i]) == type) {
      return i;
    }
  }
  return result;
}
 
function CL_CharacterAccessories::Add(Character* accessory,  int zindex, int type) {
  int index = this.MakeRoomForZIndex(zindex);
  //CL_Console.Log(String.Format("new index for ID:%d : %d", accessory.ID,  index));
  if (index != -1) {
    this.Set(accessory, index,  zindex,  type);
  }
}

function CL_CharacterAccessories::UpdateRoom() {
  Character* owner = this.GetOwner();
  for(int i = 0; i < this.accessoriesCount ; i++) {
    character[this.accessories[i]].ChangeRoom(owner.Room);
  }
  this.Render();
}

protected function CL_CharacterAccessories::GetAccessoryIndex(Character* accessory) {
  for (int i = 0 ; i < MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER ; i++) {
    if (this.accessories[i] == accessory.ID) return i;
  }
  return EMPTY_CHARACTER_INDEX;
}


function CL_CharacterAccessories::SetOffsetZ(Character* accessory,  int z)
{
  int index = this.GetAccessoryIndex(accessory);
  if (index == EMPTY_CHARACTER_INDEX) return;
  this.offsetZ[index] = z;
}

function CL_CharacterAccessories::SetOffsetX(Character* accessory,  int x)
{
  int index = this.GetAccessoryIndex(accessory);
  if (index == EMPTY_CHARACTER_INDEX) return;
  this.offsetX[index] = x;
}


////

function game_start() {
  owners = new int[Game.CharacterCount];
  characterIsAccessoryOf = new int[Game.CharacterCount];
  accessoryType = new int[Game.CharacterCount];
  for (int i = 0; i < Game.CharacterCount ; i++) {
    owners[i] = EMPTY_CHARACTER_INDEX;
    characterIsAccessoryOf[i] = EMPTY_CHARACTER_INDEX;
    accessoryType[i] = -1;
  }
}


function late_repeatedly_execute_always() {
  for (int i = 0; i < newID ; i++) {
    CL_CharacterAccessories* ca = accessories[i];
    ca.Render();
  }
}

function on_event(EventType event,  int data) {
  switch(event) {
    case eEventEnterRoomBeforeFadein: {
        CL_CharacterAccessories* ca = GetCharacterAccessories(player);
        if (ca) {
          ca.UpdateRoom();
        }
      }
      break;
  }
}

///////////////////////////////////////////////////////////
bool CL_HasAccessory(this Character*,  Character* accesory) {
  CL_CharacterAccessories* characterAccessories = GetCharacterAccessories(this);
  if (characterAccessories != null) {
    return characterAccessories.Has(accesory);
  }
  return false;
}

CL_CharacterAccessories* GetOrCreateCharacterAccessories(Character* c) {
  CL_CharacterAccessories* characterAccessories = GetCharacterAccessories(c);
  if (characterAccessories == null) {
    characterAccessories = CL_CharacterAccessories.Create(c);
  }
  return characterAccessories;
}

function CL_AddAccessory(this Character*,  Character* accesory, int zindex, int type) {
  CL_CharacterAccessories* characterAccessories = GetOrCreateCharacterAccessories(this);
  characterAccessories.Add(accesory, zindex,  type);
}

function CL_RemoveAccessory(this Character*,  Character* accesory) {
  CL_CharacterAccessories* characterAccessories = GetCharacterAccessories(this);
  if (characterAccessories != null) {
    characterAccessories.Remove(accesory);
  }
}

function CL_SetAccessoryOffsetZ(this Character*,  Character* accessory,  int offsetz) {
  CL_CharacterAccessories* characterAccessories = GetCharacterAccessories(this);
  if (characterAccessories) {
    characterAccessories.SetOffsetZ(accessory,  offsetz);
  }
}

function CL_SetAccessoryOffsetX(this Character*,  Character* accessory,  int offsetx) {
  CL_CharacterAccessories* characterAccessories = GetCharacterAccessories(this);
  if (characterAccessories) {
    characterAccessories.SetOffsetX(accessory,  offsetx);
  }
} ?  #define MODULE_CL_ACCESSORIES
#define MODULE_CL_ACCESSORIES_MAX_COUNT 5 // cantidad de Characters que pueden portar accesorios
#define MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER 5 // cantidad de accesorios por Character

#define EMPTY_ZINDEX 2147483647
#define EMPTY_CHARACTER_INDEX -1

managed struct CL_CharacterAccessories {
  int ID;
  int ownerCharacterID;
  int accessories[MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER];
  int zIndexes[MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER];
  int offsetZ[MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER];
  int offsetX[MODULE_CL_ACCESSORIES_COUNT_PER_CHARACTER];
  int accessoriesCount;
  
  import static CL_CharacterAccessories* Create(Character* c);

  import function Add(Character* accessory,  int zIndex = 0, int type = 0);
  import function Remove(Character* accessory);
  import bool Has(Character* accessory);
  import function SetOffsetZ(Character* accessory,  int z);
  import function SetOffsetX(Character* accessory,  int x);

  import function RenderAccessory(int index);
  import function Render();
  import function UpdateRoom();
  
  import Character* GetOwner();
  
  ////////////////////////////
  import protected function SwapAccessories(int indexA, int indexB);
  import protected function Set(Character* accessory,  int position,  int zindex,  int type = 0);
  import int GetZindexAtIndex(int position);
  import int MakeRoomForZIndex(int zindex);
  import function Compact();
  import protected function GetAccessoryIndex(Character* accessory);

};


import function CL_AddAccessory(this Character*,  Character* accessory,  int zindex = 0,  int type = 0);
import function CL_RemoveAccessory(this Character*,  Character* accessory);
import bool CL_HasAccessory(this Character*,  Character* accessory);
import function CL_SetAccessoryOffsetZ(this Character*,  Character* accessory,  int offsetz);
import function CL_SetAccessoryOffsetX(this Character*,  Character* accessory,  int offsetx); ??+        fj????  ej??