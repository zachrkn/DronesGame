//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintHelix extends DronesStructureBlueprint;

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
	local int levels;

	currentAdd = 0;
	levels = int(RandRange(0,80));

	for(index = 0; index < levels; index++){

		v.X = BrickSize.X;
		v.Y = BrickSize.Y; 
		v.Z = BrickSize.Z * index;
		BrickRelativeLocationsArray[currentAdd] = v; 

		r.Pitch = 0; 
		r.Yaw   = (index % 24) * (65535  / 24); 
		r.Roll  = 0;
		BrickRelativeRotationsArray[currentAdd] = r;

		currentAdd++;

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