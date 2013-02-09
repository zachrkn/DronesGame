//==========================CLASS DECLARATION==================================
class DronesGravityVolume extends GravityVolume
    placeable;
	
//==========================EVENTS==========================================
event simulated Touch(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
/*
	if( GravityZ == 0 )
	{
		if( Other.Class==Class'DronesBrickKActor' )
		{
			DronesBrickKActor(Other).SetPhysics(PHYS_None);
		}
		if( Other.Class==Class'DronesBrickSMActor' )
		{
			DronesBrickSMActor(Other).SetPhysics(PHYS_None);
		}
	}
	else
	{
		if( Other.Class==Class'DronesBrickKActor' )
		{
			DronesBrickKActor(Other).SetPhysics(PHYS_RigidBody);
		}
		if( Other.Class==Class'DronesBrickSMActor' )
		{
			DronesBrickSMActor(Other).SetPhysics(PHYS_RigidBody);
		}
	}
*/
}




//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
}