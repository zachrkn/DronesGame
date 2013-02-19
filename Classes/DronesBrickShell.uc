//==========================CLASS DECLARATION==================================
class DronesBrickShell extends Actor;

//==========================ENUMERATORS==========================================
enum EAvailability
{
	AVAIL_Available,
	AVAIL_Targetted,
	AVAIL_InTransit,
	AVAIL_InStructure
};

enum EBrickType
{
	BRICKTYPE_SM,
	BRICKTYPE_KActor
};
	
//==========================VARIABLES==========================================
var Actor Brick;

var EBrickType BrickType;

var MaterialInstanceConstant MatInst;

var array<DronesBrickConstraint> ConstraintsApplied;

var EAvailability Availability;

var array<vector> VelArray;
var int NumTicksVelAtZero;

var int StructureIndex;

var vector OriginalLocation;
var rotator OriginalRotation;

//==========================EVENTS==========================================
simulated event PostBeginPlay()
{
	Brick = Spawn(class'DronesBrickSMActor',,,Location,Rotation,,);
	DronesBrickSMActor(Brick).SetBrickParentShell(Self);
	Brick.SetPhysics(PHYS_None);
	GainCollision();
	
	OriginalLocation = Location;
	OriginalRotation = Rotation;

	
	//set the physics of this invisible shell actor none
	SetPhysics(PHYS_NONE);
}

event Tick(float DeltaTime)
{
	SetLocation(Brick.Location);
	Super.Tick(DeltaTime);
}

/*
event ApplyImpulse( Vector ImpulseDir, float ImpulseMag, Vector HitBrick.Location, optional TraceHitInfo HitInfo, optional class<DamageType> DamageType )
{
	super.ApplyImpulse(ImpulseDir, ImpulseMag, HitBrick.Location, HitInfo, DamageType);
	`Log("In event ApplyImpulse");
}
*/
//==========================FUNCTIONS==========================================
function SetMaterial()
{

	local StaticMeshComponent ThisStaticMeshComponent;
	local MaterialInterface ThisMaterialInterface01;
	
	ThisMaterialInterface01 = MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant';

	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetMaterial(0, ThisMaterialInterface01);
	}

/*
	local StaticMeshComponent ThisStaticMeshComponent;
	local MaterialInterface ThisMaterialInterface01;
	local string MatName;
	local MaterialInstanceConstant MatInstConst;

	super.PostBeginPlay();

	`Log("Brick: " $Self$ " in SetMaterial function");
	`Log("Brick's internal Brick: " $Brick);
	ThisMaterialInterface01 = MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant';
	foreach Brick.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		//ThisStaticMeshComponent.SetMaterial(0, ThisMaterialInterface01);
		ThisStaticMeshComponent.SetMaterial(0, MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant');
	}

	
	MatInst = new(None) Class'MaterialInstanceConstant';
	`Log("About to call on staticmeshcomponent of brick, typecast as dronesbrickkactor");
	if( Brick.Class == Class'DronesBrickKActor' )
	{
		`Log("Brick is a dronesbrickkactor");
		MatInst.SetParent(DronesBrickKActor(Brick).StaticMeshComponent.GetMaterial(0));
	}
	else if( Brick.Class == Class'DronesBrickSMActor' )
	{
		`Log("Brick is a dronesbricksmactor");
		MatInst.SetParent(DronesBrickSMActor(Brick).StaticMeshComponent.GetMaterial(0));	
	}
	`Log("MatInst.Parent: " $MatInst.Parent);
	
	//MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant'
	
	MatName = "BrickMaterialInstanceConstant";
		
	`Log ("Trying to load "@MatName);
	MatInstConst = MaterialInstanceConstant(DynamicLoadObject(MatName, class'MaterialInstanceConstant'));
	
//	`Log ("loaded "@MatInstConst@MatInstConst.GetMaterial());
	`Log("About to execute for loop with Brick.ComponentList");
	foreach Brick.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		`Log("In that for loop");
		ThisStaticMeshComponent.SetMaterial(0, MatInstConst);
	}
	
//	`Log("Leaving SetMaterial function");
*/
}

function DestroyKBrickAndSpawnSMBrick()
{
	local vector v;
	local rotator r;
	v = Brick.Location;
	r = Brick.Rotation;
	
	Brick.Destroy();
	
	Brick = Spawn(class'DronesBrickSMActor',,,v,r,,FALSE);
	
	SetPositionAndRotation(v, r);
	
	DronesBrickSMActor(Brick).SetBrickParentShell(Self);

//	CreateConstraintWithAllTouchingBricks();
		
//	DronesBrickSMActor(Brick).BrickParentShell.SetMaterial();
}

function DestroySMBrickAndSpawnKBrick()
{
	local vector v;
	local rotator r;
	v = Brick.Location;
	r = Brick.Rotation;
	
	Brick.Destroy();
	
//	`Log("In function DestroySMBrickAndSpawnKBrick BrickShell: " $Self$ " contains brick: " $Brick);
	
	Brick = Spawn(class'DronesBrickKActor',,,v,r,,FALSE);

	SetPositionAndRotation(v, r);
		
	DronesBrickKActor(Brick).SetBrickParentShell(Self);
	
//	CreateConstraintWithAllTouchingBricks();
	
//	DronesBrickKActor(Brick).BrickParentShell.SetMaterial();
}

function ToggleHighlightOn()
{
	MatInst.SetScalarParameterValue('Highlight',0.5);
}

function ToggleHighlightOff()
{
	MatInst.SetScalarParameterValue('Highlight',0.0);
}

function SetBaseToDrone(DronesDrone InDrone)
{
	Brick.SetHardAttach(TRUE);
	Brick.SetBase(InDrone, , InDrone.Mesh, 'Bone001Socket');
}

function SetBaseToSelf()
{
	Brick.SetHardAttach(FALSE);
	Brick.SetBase(none);
}

function LoseCollision()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	// set the collision so the target brick no longer collides with the other bricks
	foreach Brick.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetBlockRigidBody(FALSE);
		ThisStaticMeshComponent.SetTraceBlocking(FALSE, FALSE);
	}
}

function GainCollision()
{		
	local StaticMeshComponent ThisStaticMeshComponent;	
	foreach Brick.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetBlockRigidBody(TRUE);
		ThisStaticMeshComponent.SetTraceBlocking(TRUE, TRUE);
	}
}

function LoseMomentum()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	foreach Brick.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetRBLinearVelocity(vect(0,0,0));
		ThisStaticMeshComponent.SetRBAngularVelocity(vect(0,0,0));
	}
}

function SetPositionAndRotation(vector InLoc, rotator InRot)
{		
	local StaticMeshComponent ThisStaticMeshComponent;
	foreach Brick.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetRBPosition(InLoc);
		ThisStaticMeshComponent.SetRBRotation(InRot);
	}	
	Brick.SetLocation(InLoc);
	Brick.SetRotation(InRot);
}

function ResetPositionAndRotationToOriginal()
{		
	local StaticMeshComponent ThisStaticMeshComponent;
	foreach Brick.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetRBPosition(OriginalLocation);
		ThisStaticMeshComponent.SetRBRotation(OriginalRotation);
	}	
	Brick.SetLocation(OriginalLocation);
	Brick.SetRotation(OriginalRotation);
}
		
		
function CreateConstraintWithBrick(DronesBrickShell OtherBrick)
{
	local DronesBrickConstraint NewConstraint;
	NewConstraint = Spawn(class'DronesBrickConstraint',,,Brick.Location,,,);
	NewConstraint.InitConstraint(Brick, OtherBrick.Brick);
	OtherBrick.ConstraintsApplied.AddItem(NewConstraint);
	ConstraintsApplied.AddItem(NewConstraint);
}

function CreateConstraintWithAllTouchingBricks()
{
	local array<DronesBrickShell> TouchingBricks;
	local DronesBrickShell TouchingBrick;

	`Log("In function CreateConstraintWithAllTouchingBricks in class DronesBrickShell with Brick: " $Self);
	TraceTouchingBricks(vect(-20,-40,-15), vect(-20,40,-15), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(-20,-40,15), vect(-20,40,15), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(20,-40,-15), vect(20,40,-15), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(20,-40,15), vect(20,40,15), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(0,-40,-19.99), vect(0,40,-19.99), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(0,-40,19.99), vect(0,40,19.99), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(19.99,-40,0), vect(19.99,40,0), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(-19.99,-40,0), vect(-19.99,40,0), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(0,-40,-17), vect(0,-40,17), Brick.Location, Brick.Rotation, TouchingBricks);
	TraceTouchingBricks(vect(0,40,17), vect(0,40,-17), Brick.Location, Brick.Rotation, TouchingBricks);
	
	foreach TouchingBricks(TouchingBrick)
	{
		`Log("I am: "$Self$" which contains brick: " $Brick$ " and I'm creating constraint with: " $TouchingBrick$ " which contains brick: " $TouchingBrick.Brick);
		CreateConstraintWithBrick(TouchingBrick);
	}
}

/*
function RemoveConstraintsFromSelfAndThoseConstrainedTo()
{
	// remove constraints from PickUpBrick, remove the reference to those constraints from the other bricks they affected, and delete the constraints
	for (i=0; i<PickUpBrick.ConstraintsApplied.Length; i++)
	{
		Constraint = PickUpBrick.ConstraintsApplied[i];
		DronesBrickKActor(Constraint.ConstraintActor1).BrickParentShell.ConstraintsApplied.RemoveItem(Constraint);
		DronesBrickKActor(Constraint.ConstraintActor2).BrickParentShell.ConstraintsApplied.RemoveItem(Constraint);
		Constraint.Destroy();
	}
}
*/

function TraceTouchingBricks(vector StartTraceVectorOffset, vector EndTraceVectorOffset, vector InBrickLocation, rotator InBrickRotation, out array<DronesBrickShell> TouchingBricks)
{
	local vector StartTraceLoc, EndTraceLoc, HitLoc, HitNorm, TraceExtent;
	local DronesBrickKActor TraceHitKBrick;
	local DronesBrickSMActor TraceHitSMBrick;
	
	local float steps, counter;
	
	StartTraceLoc = InBrickLocation + (StartTraceVectorOffset >> InBrickRotation);
	EndTraceLoc = InBrickLocation + (EndTraceVectorOffset >> InBrickRotation);
	TraceExtent = vect(2,2,2);
	
	steps = 100;
	for(counter=1/steps;counter<1;counter+=1/steps)
	{
		//DrawDebugBox(StartTraceLoc+counter*(EndTraceLoc-StartTraceLoc),TraceExtent,255,255,255,true);
	}
	
	foreach TraceActors(class'DronesBrickKActor', TraceHitKBrick, HitLoc, HitNorm, EndTraceLoc, StartTraceLoc, TraceExtent) 
	{
		`Log("BrickShell: " $Self$ " which contains brick: " $Brick$ " TRACEHIT this kbrick: " $TraceHitKBrick.BrickParentShell$ " which contains brick: " $TraceHitKBrick);
		if( TraceHitKBrick.BrickParentShell != Self)
		{
			`Log("That brick's brick shell does not equal THIS brick shell.");
			if( TouchingBricks.Find(TraceHitKBrick.BrickParentShell) == -1 )
			{
				`Log("That brick isn't already in the Touching Bricks array, so adding it!");
				TouchingBricks.AddItem(TraceHitKBrick.BrickParentShell);
			}
		}
	}
	
	foreach TraceActors(class'DronesBrickSMActor', TraceHitSMBrick, HitLoc, HitNorm, EndTraceLoc, StartTraceLoc, TraceExtent) 
	{ 
		`Log("BrickShell: " $Self$ " which contains brick: " $Brick$ " tracehit this SMbrick: " $TraceHitSMBrick.BrickParentShell$ " which contains brick: " $TraceHitSMBrick);
		if( TraceHitSMBrick.BrickParentShell != Self)
		{
			`Log("That brick's brick shell does not equal THIS brick shell.");
			if( TouchingBricks.Find(TraceHitSMBrick.BrickParentShell) == -1 )
			{
				`Log("That brick isn't already in the Touching Bricks array, so adding it!");
				TouchingBricks.AddItem(TraceHitSMBrick.BrickParentShell);
			}
		}
	}
}


//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	BrickType=BRICKTYPE_KActor
	bHidden=TRUE
/*
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=DronesPackage.Meshes.Brick_large_mesh

		BlockRigidBody=FALSE
		CollideActors=FALSE
		BlockActors=FALSE
		bNotifyRigidBodyCollision=FALSE
		ScriptRigidBodyCollisionThreshold=0.0001
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		HiddenEditor=TRUE
		HiddenGame=TRUE		

    End Object
	Components.Add(StaticMeshComponent0)
	
	CollisionComponent=StaticMeshComponent0
*/
}

