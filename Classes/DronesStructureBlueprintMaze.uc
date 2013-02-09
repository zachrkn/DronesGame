//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintMaze extends DronesStructureBlueprint;

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
	local int index3; 
	local int levels;
	local array<float> yawIndex;

	currentAdd = 0;
	levels = (int(RandRange(3,5)) * 2);

	//Creaqte an Array with all the correspoing Random index... to build the maze
	for(index2 = 0; index2 < levels * 2; index2++){

		for(index3 = 0; index3 < levels * 2; index3++){

			yawIndex.AddItem(RandRange(0,2));

			currentAdd++;

		}

	}

	currentAdd = 0;
	for(index = 0; index < levels; index++){

		for(index2= 0; index2 < levels * 2; index2++){

			for(index3 = 0; index3 < levels * 2; index3++){

				v.X = -(BrickSize.X * index3) * 2;
				v.Y = -(BrickSize.X * index2) * 2; 
				v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; 

				r.Pitch = 0; 

				if(yawIndex[currentAdd % yawIndex.length] > 1){
					r.Yaw = - 65535 / 16;
				}
				else {
					r.Yaw = 65535 / 16;
				}
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