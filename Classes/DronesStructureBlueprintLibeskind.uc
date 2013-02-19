//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintLibeskind extends DronesStructureBlueprint;

//==========================VARIABLES==========================================
var int NumLayers;

//==========================EVENTS==========================================
event PostBeginPlay()
{
	SetBrickRelativeLocationsArray();
	SetBrickRelativeRotationsArray();
	InitializeBrickWorldLocationsAndRotationsArrays();
}

//==========================FUNCTIONS==========================================
function SetBrickRelativeLocationsArray()
{
	local vector v;
	local rotator r;
	local int currentAdd;
	local int index;
	local int index2;
	local int index3; //this setting up the variables at the top this gets old VERY quickly!
	local int levels;

		levels = RandRange(3,8);
		currentAdd = 0;

		for(index = levels; index >= 0; index--){ //this should be counting down, so we build it from the bottom up...

			//this is a pyramind with 20 levels... for each level remove two columns and 2 rows...

			//Let's draw the columns
			for(index2 = 0; index2 < index; index2++){

				//Let's draw the Rows
				for(index3 = 0; index3 < index; index3++){

					v.X = -(BrickSize.X * (index2 + (index * 0.5))); // BrickSize.X, - BrickSize.X
					v.Y = -(BrickSize.Y * (index3 + (index * 0.5))); //BrickSize.Y, - BrickSize.Y
					v.Z = BrickSize.Z * (levels - index);
					BrickRelativeLocationsArray[currentAdd] = v;

					r.Pitch = 0; 
					r.Yaw = 0; 
					r.Roll = 0;
					BrickRelativeRotationsArray[currentAdd] = r;

					currentAdd++;

				}

			}
		}
}

function SetBrickRelativeRotationsArray()
{
/*
	local int i;
	local rotator r;
	r.Pitch = 0; r.Yaw = 0; r.Roll = 0;
	for (i=0; i<NumLayers*15; i++)
	{
		BrickRelativeRotationsArray[i] = r;
	}
*/
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	NumLayers=8
}