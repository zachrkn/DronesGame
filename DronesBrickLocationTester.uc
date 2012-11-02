//==========================CLASS DECLARATION==================================
class DronesBrickLocationTester extends KActor
    placeable;
	
//==========================VARIABLES==========================================


//==========================EVENTS==========================================
simulated event PostBeginPlay()
{
	//`Log("In PostBeginPlay of DronesBrickLocationTester");
	super.PostBeginPlay();
	StaticMeshComponent.BodyInstance.EnableCollisionResponse( false );
}

//==========================FUNCTIONS==========================================

function bool DoesBrickOverlap()
{
	local Actor traceHit;
	local vector hitLoc, hitNorm, startTraceLoc, endTraceLoc, traceExtent;
	
	local SkeletalMeshComponent ThisSkeletalMeshComponent;

	foreach ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket07', startTraceLoc);
		ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket08', endTraceLoc);		
	}
		
	traceExtent.X = 19.9;
	traceExtent.Y = 19.9;
	traceExtent.Z = 19.9;
	
	traceHit = Trace(hitLoc, hitNorm, endTraceLoc, startTraceLoc, ,traceExtent, ,);
	//`Log("DronesBrickLocation tester here.  I ran a trace hit through my volume, and here's the result: "$traceHit);
	
	if(traceHit==NONE)
	{
		return FALSE;
	}
	else
	{
		//`Log("traceHit "$traceHit$" traceHit.class "$traceHit.class);
		if(traceHit.class == class'DronesBrickKActor')
		{
			return TRUE;
		}
		else
		{
			return FALSE;
		}
	}
}


DefaultProperties
{	
	bLimitMaxPhysicsVelocity=TRUE
	MaxPhysicsVelocity=0
	bWakeOnLevelStart=FALSE
	bStatic=FALSE
	bNoDelete=FALSE
	bCollideWorld=TRUE
	bCollideActors=TRUE
	bBlockActors=FALSE
	bMovable=TRUE
	bNoEncroachCheck=FALSE

	Begin Object Name=StaticMeshComponent0
        StaticMesh=DronesPackage.Meshes.Brick_large_mesh
		HiddenEditor=TRUE
		HiddenGame=TRUE
		BlockRigidBody=FALSE
		CollideActors=TRUE
		BlockActors=FALSE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
	End Object
	
	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bOwnerNoSee=FALSE
		BlockRigidBody=FALSE
		CollideActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockActors=FALSE
		bNotifyRigidBodyCollision=FALSE
		HiddenEditor=TRUE
		HiddenGame=TRUE
		//What to change if you'd like to use your own meshes and animations
	  SkeletalMesh=SkeletalMesh'DronesPackage.SkeletalMeshes.brick_large_skeletalmesh'
	End Object
	Components.Add(InitialSkeletalMesh);
}

