//==========================CLASS DECLARATION==================================
class DronesBrickKActor extends KActor
//class DronesBrickKActor extends KAsset
    placeable;
	
//==========================ENUMERATORS==========================================
enum EAvailability
{
	AVAIL_Available,
	AVAIL_InTransit,
	AVAIL_InStructure
};	
	
//==========================VARIABLES==========================================
var bool bAvailable;
var MaterialInstanceConstant matInst;

var array<DronesBrickConstraint> ConstraintsApplied;

var EAvailability Availability;

//==========================EVENTS==========================================
/*
event RigidBodyCollision (PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
	`Log("RBC! Brick: "$Self$" Location: "$Location$" OtherComponent: "$OtherComponent$ " OtherComponent.Owner: "$OtherComponent.Owner);
}

event HitWall (Object.Vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	super.HitWall(HitNormal, Wall, WallComp);
	`Log("HitWall!! Brick: "$Self$" Location: "$Location$" Wall: "$Wall);
}

event Bump (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	super.Bump(Other, OtherComp, HitNormal);
	`Log("Bump!! Brick: "$Self$" Location: "$Location$" Other "$Other);	
}

event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	`Log("Touch!! Brick: "$Self$" Location: "$Location$" Other "$Other);	
}
*/
simulated event FellOutOfWorld (class<DamageType> dmgType)
{
	DronesGame(WorldInfo.Game).Bricks.RemoveItem(Self);
	Destroy();
}

simulated event OutsideWorldBounds ()
{
	DronesGame(WorldInfo.Game).Bricks.RemoveItem(Self);
	Destroy();
}

simulated event PostBeginPlay()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	local MaterialInterface ThisMaterialInterface01;

	super.PostBeginPlay();

	ThisMaterialInterface01 = MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant';
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetMaterial(0, ThisMaterialInterface01);
	}
	
	matInst = new(None) Class'MaterialInstanceConstant';
    matInst.SetParent(StaticMeshComponent.GetMaterial(0));
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetMaterial(0, matInst);
	}		
}

event Tick (float DeltaTime)
{
	local DronesBrickConstraint ThisConstraint;
	
	foreach ConstraintsApplied(ThisConstraint)
	{
		//`Log("Brick: "$Self$" constraint: "$ThisConstraint);
	}
	//`Log("Tick! Brick: "$Self$" Location: "$Location$" Rotation: "$Rotation);
}

event ApplyImpulse( Vector ImpulseDir, float ImpulseMag, Vector HitLocation, optional TraceHitInfo HitInfo, optional class<DamageType> DamageType )
{
	super.ApplyImpulse(ImpulseDir, ImpulseMag, HitLocation, HitInfo, DamageType);
	`Log("In event ApplyImpulse");
}

//==========================FUNCTIONS==========================================
function ToggleHighlightOn()
{
	matInst.SetScalarParameterValue('Highlight',0.5);
}

function ToggleHighlightOff()
{
	matInst.SetScalarParameterValue('Highlight',0.0);
}

function SetBaseToDrone(DronesDrone InDrone)
{
	SetHardAttach(TRUE);
	SetBase(InDrone, , InDrone.Mesh, 'Bone001Socket');
	// set physics to interpolating so the brick will move along with the drone correctly
	SetPhysics(PHYS_Interpolating);
}

function LoseCollision()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	// set the collision so the target brick no longer collides with the other bricks
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetBlockRigidBody(FALSE);
		ThisStaticMeshComponent.SetTraceBlocking(FALSE, FALSE);
	}
}

function SetBaseToSelf()
{
	SetHardAttach(FALSE);
	SetBase(none);
	// set physics to rigid body so the brick moves and acts like a brick again
	//SetPhysics(PHYS_RigidBody);
	SetPhysics(PHYS_NONE);
}

function LoseMomentum()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetRBLinearVelocity(vect(0,0,0));
		ThisStaticMeshComponent.SetRBAngularVelocity(vect(0,0,0));
	}
}

function GainCollision()
{		
	local StaticMeshComponent ThisStaticMeshComponent;	
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetBlockRigidBody(TRUE);
		ThisStaticMeshComponent.SetTraceBlocking(TRUE, TRUE);
	}
}


function SetPositionAndRotation(vector InLoc, rotator InRot)
{		
	local StaticMeshComponent ThisStaticMeshComponent;
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetRBPosition(InLoc);
		ThisStaticMeshComponent.SetRBRotation(InRot);
	}	
	SetLocation(InLoc);
	SetRotation(InRot);
}
			
function CreateConstraintWithBrick(DronesBrickKActor InBrick)
{
	local DronesBrickConstraint NewConstraint;
	NewConstraint = Spawn(class'DronesBrickConstraint',,,Location,,,);
	NewConstraint.InitConstraint(Self, InBrick);
	InBrick.ConstraintsApplied.AddItem(NewConstraint);
	ConstraintsApplied.AddItem(NewConstraint);
}

function CreateConstraintWithAllTouchingBricks()
{
	local array<DronesBrickKActor> TouchingBricks;
	local DronesBrickKActor TouchingBrick;

	TraceTouchingBricks(vect(-20,-40,-15), vect(-20,40,-15), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(-20,-40,15), vect(-20,40,15), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(20,-40,-15), vect(20,40,-15), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(20,-40,15), vect(20,40,15), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(0,-40,-19.99), vect(0,40,-19.99), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(0,-40,19.99), vect(0,40,19.99), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(19.99,-40,0), vect(19.99,40,0), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(-19.99,-40,0), vect(-19.99,40,0), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(0,-40,-17), vect(0,-40,17), Location, Rotation, TouchingBricks);
	TraceTouchingBricks(vect(0,40,17), vect(0,40,-17), Location, Rotation, TouchingBricks);
	
	foreach TouchingBricks(TouchingBrick)
	{
		`Log("I am: "$Self$" creating constraint with: "$TouchingBrick);
		CreateConstraintWithBrick(TouchingBrick);
	}
}

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


//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bAvailable=TRUE

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

		BlockRigidBody=TRUE
		CollideActors=TRUE
		BlockActors=TRUE
		bNotifyRigidBodyCollision=TRUE
		ScriptRigidBodyCollisionThreshold=0.0001
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		RBChannel=RBCC_Untitled2
		RBCollideWithChannels=(Default=TRUE, GameplayPhysics=FALSE, Untitled1=FALSE, Untitled2=TRUE)
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

