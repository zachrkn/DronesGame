//==========================CLASS DECLARATION==================================
class DronesDroneAIController extends AIController
	DependsOn(DronesGame);
	
//==========================VARIABLES==========================================
var DronesBrickShell PickUpBrick;

var bool bHoldingBrick;

var vector DropLocation;
var rotator DropRotation;

var vector DestinationRangeCenter;
var vector DestinationRangeSize;

var DronesStructureBlueprint StructureBlueprint;

var DronesDrone PotentialMate;

var bool bRemovingBrickState;

var int StructureIndex;

//==========================EVENTS==========================================
event Possess( Pawn inPawn, bool bVehicleTransition)
{
//	local vector v;
	super.Possess(inPawn, bVehicleTransition);
}

//==========================STATES==========================================
auto state Idle
{
	local DronesDrone Drone;
	
	event Tick (float DeltaTime)
    {
		EveryTickStuff();
/*
		`Log("in Idle state Tick");
		// find out if there are any bricks occupying blueprint space that are not exactly aligned
		if( GetFirstBrickOccupyingBlueprintSpaceThatIsOutOfAlignment(StructureBlueprint, PickUpBrick) )
		{
			`Log("a brick occupying blueprint space was found");
			GotoState('GetBrick');
		}
*/

		if( GetFirstEmptyBlueprintLocationAndRotation(StructureBlueprint, DropLocation, DropRotation) )
		{	

			if(DoesAnAvailableBrickExistInArray( DronesGame(WorldInfo.Game).Bricks ))
			{			
				//PickUpBrick = GetClosestAvailableBrickInArray( DronesGame(WorldInfo.Game).Bricks, Pawn.Location );
				PickUpBrick = GetClosestAvailableBrickUsingPools(Pawn.Location);
			}
			else
			{
				PickUpBrick = GetRandomInStructureBrick( DronesGame(WorldInfo.Game).Bricks );
			}
			
			PickUpBrick.Availability = AVAIL_Targetted;
			GotoState('GetBrick');
		}
		else
		{
			Foreach AllActors(class'DronesDrone', Drone)
			{
				//`Log("I am: "$Pawn$" and Im looking at Drone: "$Drone);
				if( Drone != Pawn )
				{
					//`Log("Drone "$Drone$" is my match! I'm gonna fuck the bejesus outta that ho!");
					PotentialMate = Drone;
				}
			}
			GotoState('Mate');
		}
		
    }
Begin:
}

state GetBrick
{
	local int i;
	local DronesBrickConstraint Constraint;
	
	event Tick (float DeltaTime)
	{
		EveryTickStuff();	
		
		// check to make sure the brick is still available; if it's not, go back to idle
		if ( (PickUpBrick.Availability == AVAIL_InTransit) || (PickUpBrick.Availability == AVAIL_InStructure) )
		{
			GotoState('Idle');
		}
		
		// if the Drone reaches the brick, disappear the brick, make it unavailable, and pick an unoccupied brick location to place the held brick
		if ( IsPawnAtTargetBrick() )
		{		
			//`Log("Drone: " $Self$ " is at brick");
			//`Log("In state GetBrick, checking to see if there is an empty blueprint location, and to set DropLocation");
			if( GetFirstEmptyBlueprintLocationAndRotation(StructureBlueprint, DropLocation, DropRotation) )
			{			
				//`Log("Drone: " $Self$ " Got an empty blueprint location: " $DropLocation);
				PickUpBrick.SetBaseToDrone(DronesDrone(Pawn));
				// set physics to interpolating so the brick will move along with the drone correctly
				PickUpBrick.Brick.SetPhysics(PHYS_Interpolating);
				PickUpBrick.LoseCollision();
				
				PickUpBrick.Availability = AVAIL_InTransit;
				
				bHoldingBrick = TRUE;
				
				GotoState('PlaceBrick');
			}
			else
			{
				GotoState('Idle');
			}	
		}
		// if drone is not at the PickUpBrick yet, keep moving toward it
		else
		{
			MoveDroneTowardLocation(PickUpBrick.Brick.Location, DeltaTime);
		}
	}

Begin:
}

state PlaceBrick
{
	event Tick (float DeltaTime)
	{
		EveryTickStuff();
		if ( IsPawnAtLocation(DropLocation) )
		{
//			`Log("Drone is at drop location");
						
			// check to make sure the DropLocation is still unoccupied; if it is, get a new drop location
			if ( IsBrickSizedLocationOccupied(DropLocation,DropRotation) )
			{
				if( !GetFirstEmptyBlueprintLocationAndRotation(StructureBlueprint, DropLocation, DropRotation) )
				{	
					GotoState('Idle');
				}
			}
			else
			{
				PickUpBrick.SetBaseToSelf();
				PickUpBrick.Brick.SetPhysics(PHYS_None);
				//`Log("Now going to make brick lose its momentum");
				//PickUpBrick.LoseMomentum();
				//`Log("Now going to make brick gain collision");
				PickUpBrick.GainCollision();
				//`Log("Now going to set brick's position and rotation");
				PickUpBrick.SetPositionAndRotation(DropLocation, DropRotation);
				
				//`Log("Dropped PickUpBrick.  PickUpBrick.Location: "$PickUpBrick.Location$" and PickUpBrick.Rotation: "$PickUpBrick.Rotation);
																
				// change the brick's availablity status to instructure
				PickUpBrick.Availability = AVAIL_InStructure;
				
				bHoldingBrick = FALSE;
													
				GotoState('Idle');
			}
		}
		else
		{
			MoveDroneTowardLocation(DropLocation, DeltaTime);
		}
	}
	
Begin:
}
/*
state GetBrickToRemove
{
	local int i;
	local DronesBrickConstraint Constraint;

	event Tick (float DeltaTime)
	{
		EveryTickStuff();	
		
		// if the Drone reaches the brick, disappear the brick, make it unavailable, and pick an unoccupied brick location to place the held brick
		if ( IsPawnAtTargetBrick() )
		{			
			PickUpBrick.Availability = AVAIL_InTransit;
				
			bHoldingBrick = TRUE;
			
			// if there's an empty blueprint location for this brick to go, that would be the best place for it rather than removing it from the structure
			if( GetFirstEmptyBlueprintLocationAndRotation(StructureBlueprint, DropLocation, DropRotation) )
			{				
				GotoState('PlaceBrick');
			}
			else
			{
//				DropLocation = GetRandomDropLocationForRemovingBrick;
				GotoState('PlaceBrickRemove');
			}
		}
		// if drone is not at the PickUpBrick yet, keep moving toward it
		else
		{
			MoveDroneTowardLocation(PickUpBrick.Location, DeltaTime);
		}
	}

Begin:
}

state PlaceBrickAtRemovalLocation
{

	event Tick (float DeltaTime)
	{
		EveryTickStuff();
		if ( IsPawnAtLocation(DropLocation) )
		{
			// check to make sure the DropLocation is still unoccupied; if it is, get a new drop location
			if ( IsBrickSizedLocationOccupied(DropLocation,DropRotation) )
			{
				if( !GetFirstEmptyBlueprintLocationAndRotation(StructureBlueprint, DropLocation, DropRotation) )
				{	
					GotoState('Idle');
				}
			}
			else
			{
				PickUpBrick.SetBaseToSelf();
				PickUpBrick.LoseMomentum();
				PickUpBrick.GainCollision();
				PickUpBrick.SetPositionAndRotation(DropLocation, DropRotation);
				PickUpBrick.Availability = AVAIL_Available;							
				
				bHoldingBrick = FALSE;
													
				GotoState('Idle');
			}
		}
		else
		{
			MoveDroneTowardLocation(DropLocation, DeltaTime);
		}
	}
	
Begin:
}
*/
state Mate
{	
	event Tick (float DeltaTime)
	{
		EveryTickStuff();
		if ( IsPawnAtLocation(PotentialMate.Location) )
		{
			SpawnChildDrone(DronesDrone(Pawn), PotentialMate);

			GotoState('Die');
		}
		else
		{
			MoveDroneTowardLocation(PotentialMate.Location, DeltaTime);
		}
	}
Begin:
}

state Die
{
	event Tick (float DeltaTime)
	{
		DronesDrone(Pawn).Kill();
	}
Begin:
}

state PauseDrone
{

Begin:
}


//=========================FUNCTIONS==========================================
function EveryTickStuff()
{
/*
	Pawn.SetDrawScale(Pawn.DrawScale-0.00015);
	If(Pawn.DrawScale <= 0.05)
	{
		if( bHoldingBrick )
		{
			PickUpBrick.SetBaseToSelf();
			PickUpBrick.GainCollision();
			PickUpBrick.Availability = AVAIL_Available;
		}
		DronesDrone(Pawn).Kill();
	}
*/
}

function bool GetFirstEmptyBlueprintLocationAndRotation(DronesStructureBlueprint Blueprint, out vector InLoc, out rotator InRot)
{
	local vector CurrentLoc;
	local rotator CurrentRot;
	local int i;
	
//	InLoc = vect(100, 180, 100);
//	return TRUE;

//	`Log("Drone: " $Self$ " in function GetFirstEmptyBlueprintLocationAndRotation, going to loop through all the locations");
	for (i=0; i<Blueprint.BrickWorldLocationsArray.Length; i++)
	{
		CurrentLoc = Blueprint.BrickWorldLocationsArray[i];
		CurrentRot = Blueprint.BrickWorldRotationsArray[i];
//		`Log("i = " $i$ " ... BlueprintLoc: " $CurrentLoc );
		if( !IsBrickSizedLocationOccupied(CurrentLoc, CurrentRot) )
		{
			InLoc = CurrentLoc;
			InRot = CurrentRot;
//			`Log("First empty Blueprint Location: "$CurrentLoc$" and Rotation: "$CurrentRot);
			return TRUE;
		}
	}
	`Log("No empy blueprint locations");
	return FALSE;
}

function bool GetFirstBrickOccupyingBlueprintSpaceThatIsOutOfAlignment(DronesStructureBlueprint Blueprint, out DronesBrickShell OutBrick)
{
	local vector CurrentLoc;
	local rotator CurrentRot;
	local int i;
	local array<DronesBrickShell> OccupyingBricks;
	local DronesBrickShell Brick;
	
//	`Log("Function called - GetFirstBrickOccupyingSpace...");
//	`Log("Blueprint.class.name "$Blueprint.class.name);
	for (i=0; i<Blueprint.BrickWorldLocationsArray.Length; i++)
	{
		CurrentLoc = Blueprint.BrickWorldLocationsArray[i];
		CurrentRot = Blueprint.BrickWorldRotationsArray[i];
//		`Log("Blueprint slot location: "$CurrentLoc$" and rotation: "$CurrentRot);
		GetBricksOccupyingBrickSizedLocation(CurrentLoc, CurrentRot, OccupyingBricks);
//		`Log("Number of bricks occupying the current blueprint slot location: "$OccupyingBricks.Length);
		if( OccupyingBricks.Length > 0)
		{
			foreach OccupyingBricks(Brick)
			{
				if( (Brick.Brick.Location != CurrentLoc) || (OutBrick.Rotation != CurrentRot) )
				{
					OutBrick = Brick;
					return TRUE;
				}
			}
		}
	}
	return FALSE;
}

function bool SpecialTrace(vector StartTraceVectorOffset, vector EndTraceVectorOffset, vector InLocation, rotator InRotation)
{
	local vector StartTraceLoc, EndTraceLoc, HitLoc, HitNorm;
	local Actor TraceHit;
	StartTraceLoc = InLocation + (StartTraceVectorOffset >> InRotation);
	EndTraceLoc = InLocation + (EndTraceVectorOffset >> InRotation);
	TraceHit = Trace(HitLoc, HitNorm, EndTraceLoc, StartTraceLoc);
	If(TraceHit != NONE)
	{
		//DrawDebugLine(StartTraceLoc, EndTraceLoc,255,0,0,true);
		return TRUE;
	}
		//DrawDebugLine(StartTraceLoc, EndTraceLoc,0,255,0,true);
	return FALSE;
}

function bool IsBrickSizedLocationOccupied(vector InLocation, rotator InRotation)
{
	if( SpecialTrace(vect(-19.95,-39.5,-19.95), vect(-19.95,39.5,-19.95), InLocation, InRotation) ) {
		return TRUE;
	}
	else if( SpecialTrace(vect(-19.95,-39.5,19.95), vect(-19.95,39.5,19.95), InLocation, InRotation) ) {
		return TRUE;
	}
	else if( SpecialTrace(vect(19.95,-39.5,-19.95), vect(19.95,39.5,-19.95), InLocation, InRotation) ) {
		return TRUE;
	}
	else if( SpecialTrace(vect(19.95,-39.5,19.95), vect(19.95,39.5,19.95), InLocation, InRotation) ) {
		return TRUE;
	}
	
	else if( SpecialTrace(vect(0,-39.5,-19.95), vect(0,39.5,-19.95), InLocation, InRotation) ) {
		return TRUE;
	}
	else if( SpecialTrace(vect(0,-39.5,19.95), vect(0,39.5,19.95), InLocation, InRotation) ) {
		return TRUE;
	}
	else if( SpecialTrace(vect(19.95,-39.5,0), vect(19.95,39.5,0), InLocation, InRotation) ) {
		return TRUE;
	}
	else if( SpecialTrace(vect(-19.95,-39.5,0), vect(-19.95,39.5,0), InLocation, InRotation) ) {
		return TRUE;
	}

	else if( SpecialTrace(vect(0,-39.5,-19.95), vect(0,-39.5,19.95), InLocation, InRotation) ) {
		return TRUE;
	}
	else if( SpecialTrace(vect(0,39.5,19.95), vect(0,39.5,-19.95), InLocation, InRotation) ) {
		return TRUE;
	}
	return FALSE;
}

function GetBricksOccupyingBrickSizedLocation(vector InLocation, rotator InRotation, optional out array<DronesBrickShell> OccupyingBricks)
{
	SpecialTraceGetAllTraceHitBricks(vect(-19.95,-39.5,-19.95), vect(-19.95,39.5,-19.95), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(-19.95,-39.5,19.95), vect(-19.95,39.5,19.95), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(19.95,-39.5,-19.95), vect(19.95,39.5,-19.95), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(19.95,-39.5,19.95), vect(19.95,39.5,19.95), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(0,-39.5,-19.95), vect(0,39.5,-19.95), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(0,-39.5,19.95), vect(0,39.5,19.95), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(19.95,-39.5,0), vect(19.95,39.5,0), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(-19.95,-39.5,0), vect(-19.95,39.5,0), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(0,-39.5,-19.95), vect(0,-39.5,19.95), InLocation, InRotation, OccupyingBricks);
	SpecialTraceGetAllTraceHitBricks(vect(0,39.5,19.95), vect(0,39.5,-19.95), InLocation, InRotation, OccupyingBricks);
}

function SpecialTraceGetAllTraceHitBricks(vector StartTraceVectorOffset, vector EndTraceVectorOffset, vector InLocation, rotator InRotation, optional out array<DronesBrickShell> TraceHitBricks)
{
	local vector StartTraceLoc, EndTraceLoc, HitLoc, HitNorm;
	local DronesBrickKActor TraceHitKBrick;
	local DronesBrickSMActor TraceHitSMBrick;
	StartTraceLoc = InLocation + (StartTraceVectorOffset >> InRotation);
	EndTraceLoc = InLocation + (EndTraceVectorOffset >> InRotation);
	foreach TraceActors(class'DronesBrickKActor', TraceHitKBrick, HitLoc, HitNorm, EndTraceLoc, StartTraceLoc) 
	{
		if( TraceHitBricks.Find(TraceHitKBrick.BrickParentShell) == -1 )
		{
			TraceHitBricks.AddItem(TraceHitKBrick.BrickParentShell);
		}
	}
	foreach TraceActors(class'DronesBrickSMActor', TraceHitSMBrick, HitLoc, HitNorm, EndTraceLoc, StartTraceLoc) 
	{
		if( TraceHitBricks.Find(TraceHitSMBrick.BrickParentShell) == -1 )
		{
			TraceHitBricks.AddItem(TraceHitSMBrick.BrickParentShell);
		}
	}
}

function bool DoesAnAvailableBrickExistInArray(array<DronesBrickShell> Bricks)
{
	local DronesBrickShell Brick;

	// if there are still available bricks, return TRUE, otherwise return FALSE

//	`Log("Drone: " $Self$ " in function DoesAnAvailableBrickExist");
	foreach Bricks(Brick)
	{
		if( Brick.Availability == AVAIL_Available )
		{
//			`Log("Returning true");
			return TRUE;
		}
	}
//	`Log("Returning false");
	return FALSE;
}

// NEEDS OPTIMIZATION - EVERY TIME IT DOES THIS, IT GOES THROUGH EVERY BRICK IN THE BRICKS ARRAY - it's a framerate killer with 10k bricks
function DronesBrickShell GetClosestAvailableBrickInArray(array<DronesBrickShell> BrickArray, vector InLoc)
{
	local DronesBrickShell CurrentBrick;
	local float CurrentDistance;
	local DronesBrickShell ClosestBrick;
	local float ClosestDistance;
	ClosestDistance = 100000000000;
/*	
	foreach BrickArray(CurrentBrick)
	{
		if( CurrentBrick.Availability == AVAIL_Available )
		{
			return CurrentBrick;
		}
	}
*/

	//`Log("Drone: " $Self$ " in function GetClosestAvailableBrickInArray");
	foreach BrickArray(CurrentBrick)
	{
		if( CurrentBrick.Availability == AVAIL_Available)
		{
			CurrentDistance = vSize(CurrentBrick.Location - InLoc);
			if ( CurrentDistance < ClosestDistance )
			{
				ClosestDistance = CurrentDistance;
				ClosestBrick = CurrentBrick;
			}
		}
	}
	//`Log("ClosestBrick: " $ClosestBrick$ " at location: " $closestBrick.Location);
	return ClosestBrick;

	//`Log("Drone: " $Self$ " found the closest brick.  It is: " $ClosestBrick$ " and it's internal brick is: " $ClosestBrick.Brick);
	
//	`Log("The closest brick's availability is: " $ClosestBrick.Availability);
}

function DronesBrickShell GetClosestAvailableBrickUsingPools(vector InLoc)
{
	local DronesBrickShell ClosestBrickInPool;
	local bool bNoBrickInThatPoolAvailable;
	if(InLoc.X > 0 )
	{
		if( (InLoc.Y > 0) && DoesAnAvailableBrickExistInArray(DronesGame(WorldInfo.Game).BricksPP) )
		{
			//`Log("DroneLoc is PP, so using that array");
			ClosestBrickInPool = GetClosestAvailableBrickInArray(DronesGame(WorldInfo.Game).BricksPP, InLoc);
		}
		else if( (InLoc.Y <= 0) && DoesAnAvailableBrickExistInArray(DronesGame(WorldInfo.Game).BricksPN) )
		{
			//`Log("DroneLoc is PN, so using that array");
			ClosestBrickInPool = GetClosestAvailableBrickInArray(DronesGame(WorldInfo.Game).BricksPN, InLoc);		
		}
		else
		{
			bNoBrickInThatPoolAvailable = TRUE;
		}
	}
	else
	{
		if( (InLoc.Y > 0) && DoesAnAvailableBrickExistInArray(DronesGame(WorldInfo.Game).BricksNP) )
		{
			//`Log("DroneLoc is NP, so using that array");
			ClosestBrickInPool = GetClosestAvailableBrickInArray(DronesGame(WorldInfo.Game).BricksNP, InLoc);			
		}
		else if( (InLoc.Y <= 0) && DoesAnAvailableBrickExistInArray(DronesGame(WorldInfo.Game).BricksNN) )
		{
			//`Log("DroneLoc is NN, so using that array");
			ClosestBrickInPool = GetClosestAvailableBrickInArray(DronesGame(WorldInfo.Game).BricksNN, InLoc);			
		}
		else
		{
			bNoBrickInThatPoolAvailable = TRUE;
		}
	}
	
	if( bNoBrickInThatPoolAvailable )
	{
		//`Log("in whatever pool i was drawing from, there were no available bricks!");
		foreach DronesGame(WorldInfo.Game).Bricks( ClosestBrickInPool )
		{
			if( ClosestBrickInPool.Availability == AVAIL_Available )
			{
				return ClosestBrickInPool;
			}
		}
	}
	
	return ClosestBrickInPool;
}

function DronesBrickShell GetRandomInStructureBrick(array<DronesBrickShell> BrickArray)
{
	//`Log("Getting randomInStructurebrick: " $BrickArray[ RandRange(0,BrickArray.Length) ]);
	return BrickArray[ RandRange(0,BrickArray.Length) ];
}

function vector GetRandomDropLocationForRemovingBrick()
{
	
}

function MoveDroneTowardLocation(vector InLoc, float DeltaTime)
{
	local vector NewLocation;
	local rotator NewRotation;
	local rotator RotationToFace;
	
	NewLocation = Pawn.Location + Normal(InLoc - Pawn.Location)*DronesGame(WorldInfo.Game).OverallDroneSpeed;

	If(NewLocation.Z < 80)
	{	
		// this keeps the drone from colliding with the ground and looking like a dumbfuck
		NewLocation.Z = 80;
	}

	//`Log("In GetThatBrick, i am "$Pawn$" and i'm going to my new location which is "$NewLocation);
	Pawn.SetLocation(NewLocation);
	
	RotationToFace = Rotator(InLoc-Pawn.Location);
	NewRotation = RInterpTo(Pawn.Rotation, RotationToFace,DeltaTime, 4);
	SetFocalPoint(InLoc);
	Pawn.SetRotation(NewRotation);
}

function bool IsPawnAtLocation(vector InLocation)
{
	if ( vsize(Pawn.Location-InLocation) < 100)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function bool IsPawnAtTargetBrick()
{
	if( vSize(Pawn.Location-PickUpBrick.Brick.Location) < 100)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function bool ShouldSpawnNewDrone()
{
	if( RandRange(0,100)/30.00 < Pawn.DrawScale)
	{
		//`Log("Returning TRUE");
		return TRUE;
	}
	else
	{
		//`Log("Returning FALSE");
		return FALSE;
	}
}

function InitializeRandomBlueprint()
{
	local int rand;
	rand = RandRange(0,9);
	
	switch( rand )
	{
		case 0:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintPyramid');
			break;
		case 1:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintSculptureOne');
			break;
		case 2:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintSculptureTwo');
			break;
		case 3:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintDiagonal');
			break;
		case 4:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintHelix');
			break;
		case 5:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintQuarterPyramid');
			break;
		case 6:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintTemple');
			break;
		case 7:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintLibeskind');
			break;
		default:
			StructureBlueprint = Spawn(class'DronesStructureBlueprintCube');
			break;
	}
	StructureBlueprint.StructureLocation.X = RandRange(-10000, 10000);
	StructureBlueprint.StructureLocation.Y = RandRange(-10000, 10000);
	
	//StructureBlueprint.StructureLocation.X = 0;
	//StructureBlueprint.StructureLocation.Y = 0;
	StructureBlueprint.StructureLocation.Z = 20;
	//StructureBlueprint.StructureRotation.Yaw = 20000;
	
	StructureBlueprint.InitializeBrickWorldLocationsAndRotationsArrays();
}

function SpawnChildDrone(DronesDrone ParentOne, DronesDrone ParentTwo)
{
	local DronesDrone ChildDrone;
//	`Log("In function SpawnChildDrone");
	ChildDrone = Spawn(class'DronesDrone',,,Pawn.Location,,,TRUE);
	DronesGame(WorldInfo.Game).Drones.AddItem(ChildDrone);
	ChildDrone.Controller = Spawn(class'DronesDroneAIController');
	ChildDrone.Controller.Possess(ChildDrone, FALSE);
	DronesDroneAIController(ChildDrone.Controller).InitializeChildBlueprint(ParentOne, ParentTwo, ChildDrone);
	ChildDrone.UpdateDroneColor();
}

function InitializeChildBlueprint(DronesDrone ParentOne, DronesDrone ParentTwo, DronesDrone Child)
{
	local DronesDroneAIController ParentOneController, ParentTwoController, ChildController;
	ParentOneController = DronesDroneAIController(ParentOne.Controller);
	ParentTwoController = DronesDroneAIController(ParentTwo.Controller);
	ChildController = DronesDroneAIController(Child.Controller);
	ChildController.StructureBlueprint = Spawn(class'DronesStructureBlueprintMutant');
	
//	`Log("ParentOneController.StructureBlueprint.StructureLocation "$ParentOneController.StructureBlueprint.StructureLocation$" ParentTwoController.StructureBlueprint.StructureLocation "$ParentTwoController.StructureBlueprint.StructureLocation);
	ChildController.StructureBlueprint.StructureLocation = ParentOneController.StructureBlueprint.StructureLocation + (Normal(ParentTwoController.StructureBlueprint.StructureLocation - ParentOneController.StructureBlueprint.StructureLocation)*VSize(ParentOneController.StructureBlueprint.StructureLocation - ParentTwoController.StructureBlueprint.StructureLocation) /2);
	If( RandRange(0,100) < 100)
	{
		ChildController.StructureBlueprint.StructureLocation.X = RandRange(-10000,10000);
		ChildController.StructureBlueprint.StructureLocation.Y = RandRange(-10000,10000);
	/*
		ChildController.StructureBlueprint.StructureLocation.X += RandRange(-400,400);
		ChildController.StructureBlueprint.StructureLocation.Y += RandRange(-400,400);
	*/
	}
//	`Log("ChildController.StructureBlueprint.StructureLocation "$ChildController.StructureBlueprint.StructureLocation);
	DronesStructureBluePrintMutant(ChildController.StructureBlueprint).SetBrickRelativeLocationsArray(ParentOneController.StructureBlueprint.BrickRelativeLocationsArray, ParentTwoController.StructureBlueprint.BrickRelativeLocationsArray);
	DronesStructureBluePrintMutant(ChildController.StructureBlueprint).SetBrickRelativeRotationsArray(ParentOneController.StructureBlueprint.BrickRelativeRotationsArray, ParentTwoController.StructureBlueprint.BrickRelativeRotationsArray);
	ChildController.StructureBlueprint.InitializeBrickWorldLocationsAndRotationsArrays();
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bHoldingBrick=FALSE
}