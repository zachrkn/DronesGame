//==========================CLASS DECLARATION==================================
class DronesBrickKActor extends KActor
    placeable;
	
//==========================VARIABLES==========================================
var array<vector> VelArray;
var int NumTicksVelAtZero;

var DronesBrickShell BrickParentShell;

//==========================EVENTS==========================================

event RigidBodyCollision (PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
}


event Tick (float DeltaTime)
{
//	CheckVelocityAndConvertToSMBrickIfInStasis();
}

/*
event ApplyImpulse( Vector ImpulseDir, float ImpulseMag, Vector HitLocation, optional TraceHitInfo HitInfo, optional class<DamageType> DamageType )
{
	super.ApplyImpulse(ImpulseDir, ImpulseMag, HitLocation, HitInfo, DamageType);
	`Log("In event ApplyImpulse");
}
*/
//==========================FUNCTIONS==========================================
function CheckVelocityAndConvertToSMBrickIfInStasis()
{
	local vector RunningAverage;
	local vector ThisVel;

//	`Log("Brick: " $Self$ " Velocity: " $Velocity);
	
	VelArray.AddItem(Velocity);
	
	if( VelArray.Length > 100)
	{
		VelArray.Remove(0,1);
	}
	
	foreach VelArray(ThisVel)
	{
		RunningAverage.X += Abs(ThisVel.X);
		RunningAverage.Y += Abs(ThisVel.Y);
		RunningAverage.Z += Abs(ThisVel.Z);
	}
	
	RunningAverage.X /= VelArray.Length;
	RunningAverage.Y /= VelArray.Length;
	RunningAverage.Z /= VelArray.Length;

//	`Log("Brick: " $Self$ " RunningAverage " $RunningAverage);
	
	if( Abs(Velocity.X) > 1 || Abs(Velocity.Y) > 1 || Abs(Velocity.Z) > 1 )
	{
		NumTicksVelAtZero=0;
	}
	
	if( (RunningAverage.X < 1) && (RunningAverage.Y < 1) && (RunningAverage.Z < 1) )
	{
//		`Log("Brick: "$Self$ " All at less than 1");
		NumTicksVelAtZero++;
	}
	else
	{
		NumTicksVelAtZero=0;
	}

	if( NumTicksVelAtZero>3 )
	{
		if( (BrickParentShell.Availability == AVAIL_Available) || (BrickParentShell.Availability == AVAIL_InStructure) )
		{
//			`Log("Brick: " $Self$ " I've been in stasis for a while, so calling ParentShell function to replace KBrick with SMBrick!");
			BrickParentShell.DestroyKBrickAndSpawnSMBrick();
		}
	}
}

function SetBrickParentShell(DronesBrickShell BrickParent)
{
	BrickParentShell = BrickParent;
}

/*
function TraceTouchingBricks(vector StartTraceVectorOffset, vector EndTraceVectorOffset, vector InLocation, rotator InRotation, out array<DronesBrickKActor> TouchingBricks)
{
	local vector StartTraceLoc, EndTraceLoc, HitLoc, HitNorm, TraceExtent;
	local DronesBrickKActor TraceHitBrick;
	
	local float steps, counter;
	
	StartTraceLoc = InLocation + (StartTraceVectorOffset >> InRotation);
	EndTraceLoc = InLocation + (EndTraceVectorOffset >> InRotation);
	TraceExtent = vect(2,2,2);
	
	steps = 100;
	for(counter=1/steps;counter<1;counter+=1/steps)
	{
		//DrawDebugBox(StartTraceLoc+counter*(EndTraceLoc-StartTraceLoc),TraceExtent,255,255,255,true);
	}
	
	foreach TraceActors(class'DronesBrickKActor', TraceHitBrick, HitLoc, HitNorm, EndTraceLoc, StartTraceLoc, TraceExtent) 
	{ 
		if( TouchingBricks.Find(TraceHitBrick) == -1 )
		{
			TouchingBricks.AddItem(TraceHitBrick);
		}
	}
}
*/


//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bWakeOnLevelStart=TRUE
	bStatic=FALSE
	bNoDelete=FALSE
	bBlockActors=TRUE
	bMovable=TRUE
	bCollideActors=TRUE
	
	bNoEncroachCheck=FALSE
	
	bPawnCanBaseOn=TRUE
	bCanStepUpOn=FALSE

	Begin Object Name=StaticMeshComponent0
        StaticMesh=DronesPackage.Meshes.Brick_large_mesh
		CastShadow=TRUE
		bCastDynamicShadow=TRUE
		bUsePrecomputedShadows=FALSE
		MaxDrawDistance=0
		BlockRigidBody=TRUE
		CollideActors=TRUE
		BlockActors=TRUE
		bNotifyRigidBodyCollision=TRUE
		ScriptRigidBodyCollisionThreshold=0.0001
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		//RBChannel=RBCC_Untitled2
		RBChannel=RBCC_Default
		RBCollideWithChannels=(Default=TRUE, GameplayPhysics=TRUE, Untitled1=FALSE, Untitled2=TRUE)
		Materials[0]=MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant';
    End Object

	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
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

