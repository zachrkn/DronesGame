//==========================CLASS DECLARATION==================================
class DronesStructureBlueprint extends Actor;

//==========================VARIABLES==========================================
var array<vector> BrickRelativeLocationsArray;
var array<vector> BrickWorldLocationsArray;
var array<rotator> BrickRelativeRotationsArray;
var array<rotator> BrickWorldRotationsArray;
var vector StructureLocation;
var rotator StructureRotation;
var vector BrickSize;

//==========================FUNCTIONS==========================================
function InitializeBrickWorldLocationsAndRotationsArrays()
{
	local int i;
//	`Log("in function InitializeBrickWorldLocationsAndRotationsArrays");
//	`Log("BrickRelativeLocationsArray.Length " $BrickRelativeLocationsArray.Length);
	for( i=0; i<BrickRelativeLocationsArray.Length; i++ )
	{
		BrickWorldLocationsArray[i] = StructureLocation + BrickRelativeLocationsArray[i];
		BrickWorldRotationsArray[i] = StructureRotation + BrickRelativeRotationsArray[i];
	}
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{
	StructureLocation=(x=0,y=0,z=18.76)
	StructureRotation=(pitch=0,yaw=0,roll=0)
	BrickSize=(x=40,y=80,z=40)
}
