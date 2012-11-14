//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintSculptureOne extends DronesStructureBlueprint;

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

	v.X = 40; 			v.Y = 140; 			v.Z = 0;
		BrickRelativeLocationsArray[0] = v;
	v.X = 40; 			v.Y = 60; 			v.Z = 0;
		BrickRelativeLocationsArray[1] = v;
	v.X = 0; 				v.Y = 60; 			v.Z = 0;
		BrickRelativeLocationsArray[2] = v;
	v.X = 0; 				v.Y = 140; 			v.Z = 0;
		BrickRelativeLocationsArray[3] = v;
	v.X = 20; 			v.Y = 80; 			v.Z = 40;
		BrickRelativeLocationsArray[4] = v;
	v.X = 20; 			v.Y = 120; 			v.Z = 40;
		BrickRelativeLocationsArray[5] = v;
	v.X = 40; 			v.Y = 120; 			v.Z = 100;
		BrickRelativeLocationsArray[6] = v;
	v.X = 0; 				v.Y = 80; 	v.Z = 100;
		BrickRelativeLocationsArray[7] = v;
	v.X = 40; 			v.Y = 200; 			v.Z = 20;
		BrickRelativeLocationsArray[8] = v;
	v.X = 0; 				v.Y = 200; 			v.Z = 20;
		BrickRelativeLocationsArray[9] = v;
	v.X = 40; 			v.Y = 0; 				v.Z = 20;
		BrickRelativeLocationsArray[10] = v;
	v.X = 0; 				v.Y = 0; 				v.Z = 20;
		BrickRelativeLocationsArray[11] = v;
	v.X = 40; 			v.Y = 200; 			v.Z = 100;
		BrickRelativeLocationsArray[12] = v;
	v.X = 0; 				v.Y = 200; 			v.Z = 100;
		BrickRelativeLocationsArray[13] = v;
	v.X = 40; 				v.Y = 0; 			v.Z = 100;
		BrickRelativeLocationsArray[14] = v;
	v.X = 0; 					v.Y = 0; 			v.Z = 100;
		BrickRelativeLocationsArray[15] = v;
	v.X = 40; 				v.Y = 160; 		v.Z = 160;
		BrickRelativeLocationsArray[16] = v;
	v.X = 0; 					v.Y = 40; 		v.Z = 160;
		BrickRelativeLocationsArray[17] = v;
}

function SetBrickRelativeRotationsArray()
{
	local rotator r;
	r.Roll = 0; 				r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[0] = r;
	r.Roll = 0; 				r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[1] = r;
	r.Roll = 0; 				r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[2] = r;
	r.Roll = 0; 				r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[3] = r;
	r.Roll = 0; 				r.Pitch = 0; 				r.Yaw = 90 * DegToUnrRot;
		BrickRelativeRotationsArray[4] = r;	
	r.Roll = 0; 				r.Pitch = 0; 				r.Yaw = 90 * DegToUnrRot;
		BrickRelativeRotationsArray[5] = r;
	r.Roll = 90 * DegToUnrRot; 	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[6] = r;
	r.Roll = 90 * DegToUnrRot; 	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[7] = r;
	r.Roll = 90 * DegToUnrRot; 	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[8] = r;
	r.Roll = 90 * DegToUnrRot; 	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[9] = r;
	r.Roll = 90 * DegToUnrRot;	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[10] = r;
	r.Roll = 90 * DegToUnrRot;	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[11] = r;
	r.Roll = 90 * DegToUnrRot; 	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[12] = r;
	r.Roll = 90 * DegToUnrRot; 	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[13] = r;
	r.Roll = 90 * DegToUnrRot;	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[14] = r;
	r.Roll = 90 * DegToUnrRot; 	r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[15] = r;
	r.Roll = 0; 				r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[16] = r;
	r.Roll = 0; 				r.Pitch = 0; 				r.Yaw = 0;
		BrickRelativeRotationsArray[17] = r;
}