//==========================CLASS DECLARATION==================================
class DronesDroneAIController extends AIController
	DependsOn(DronesGame);
	
//==========================VARIABLES==========================================
var DronesBrickKActor PickUpBrick;

var bool bHoldingBrick;

var vector DropLocation;
var rotator DropRotation;

var vector DestinationRangeCenter;
var vector DestinationRangeSize;

var DronesStructureBlueprint StructureBlueprint;

var DronesDrone PotentialMate;

var bool bRemovingBrickState;


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
		if(DoesAnAvailableBrickExist())
		{
			if( GetFirstEmptyBlueprintLocationAndRotation(StructureBlueprint, DropLocation, DropRotation) )
			{				
				PickUpBrick = GetClosestAvailableBrickInArray( DronesGame(WorldInfo.Game).Bricks, Pawn.Location );
				GotoState('GetBrick');
			}
			else
			{
				Foreach AllActors(class'DronesDrone', Drone)
				{
					`Log("I am: "$Pawn$" and Im looking at Drone: "$Drone);
					if( Drone != Pawn )
					{
						`Log("Drone "$Drone$" is my match! I'm gonna fuck the bejesus outta that ho!");
						PotentialMate = Drone;
					}
				}
				GotoState('Mate');
			}
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
		if ( PickUpBrick.Availability != AVAIL_Available )
		{
			GotoState('Idle');
		}
		
		// if the Drone reaches the brick, disappear the brick, make it unavailable, and pick an unoccupied brick location to place the held brick
		if ( IsPawnAtTargetBrick() )
		{
			//`Log("In state GetBrick, checking to see if there is an empty blueprint location, and to set DropLocation");
			if( GetFirstEmptyBlueprintLocationAndRotation(StructureBlueprint, DropLocation, DropRotation) )
			{				
				PickUpBrick.SetBaseToDrone(DronesDrone(Pawn));
				PickUpBrick.LoseCollision();
			
				// remove constraints from PickUpBrick, remove the reference to those constraints from the other bricks they affected, and delete the constraints
				for (i=0; i<PickUpBrick.ConstraintsApplied.Length; i++)
				{
					Constraint = PickUpBrick.ConstraintsApplied[i];
					DronesBrickKActor(Constraint.ConstraintActor1).ConstraintsApplied.RemoveItem(Constraint);
					DronesBrickKActor(Constraint.ConstraintActor2).ConstraintsApplied.RemoveItem(Constraint);
					Constraint.Destroy();
				}
	
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
			MoveDroneTowardLocation(PickUpBrick.Location, DeltaTime);
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
			//`Log("At drop location");
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
				
				//`Log("Dropped PickUpBrick.  PickUpBrick.Location: "$PickUpBrick.Location$" and PickUpBrick.Rotation: "$PickUpBrick.Rotation);
				
				//PickUpBrick.CreateConstraintWithBrick(AdjacentBrick); // shouldn't need this because next line should include adjacent brick
				PickUpBrick.CreateConstraintWithAllTouchingBricks();
												
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
			PickUpBrick.SetBaseToDrone(DronesDrone(Pawn));
			PickUpBrick.LoseCollision();
			
			// remove constraints from PickUpBrick, remove the reference to those constraints from the other bricks they affected, and delete the constraints
			for (i=0; i<PickUpBrick.ConstraintsApplied.Length; i++)
			{
				Constraint = PickUpBrick.ConstraintsApplied[i];
				DronesBrickKActor(Constraint.ConstraintActor1).ConstraintsApplied.RemoveItem(Constraint);
				DronesBrickKActor(Constraint.ConstraintActor2).ConstraintsApplied.RemoveItem(Constraint);
				Constraint.Destroy();
			}
	
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

}

function bool GetFirstEmptyBlueprintLocationAndRotation(DronesStructureBlueprint Blueprint, out vector InLoc, out rotator InRot)
{
	local vector CurrentLoc;
	local rotator CurrentRot;
	local int i;
	
	for (i=0; i<Blueprint.BrickWorldLocationsArray.Length; i++)
	{
		CurrentLoc = Blueprint.BrickWorldLocationsArray[i];
		CurrentRot = Blueprint.BrickWorldRotationsArray[i];
		if( !IsBrickSizedLocationOccupied(CurrentLoc, CurrentRot) )
		{
			InLoc = CurrentLoc;
			InRot = CurrentRot;
			//`Log("First empty Blueprint Location: "$CurrentLoc$" and Rotation: "$CurrentRot);
			return TRUE;
		}
	}
	return FALSE;
}

function bool GetFirstBrickOccupyingBlueprintSpaceThatIsOutOfAlignment(DronesStructureBlueprint Blueprint, out DronesBrickKActor OutBrick)
{
	local vector CurrentLoc;
	local rotator CurrentRot;
	local int i;
	local array<DronesBrickKActor> OccupyingBricks;
	local DronesBrickKActor Brick;
	
	`Log("Function called - GetFirstBrickOccupyingSpace...");
	`Log("Blueprint.class.name "$Blueprint.class.name);
	for (i=0; i<Blueprint.BrickWorldLocationsArray.Length; i++)
	{
		CurrentLoc = Blueprint.BrickWorldLocationsArray[i];
		CurrentRot = Blueprint.BrickWorldRotationsArray[i];
		`Log("Blueprint slot location: "$CurrentLoc$" and rotation: "$CurrentRot);
		GetBricksOccupyingBrickSizedLocation(CurrentLoc, CurrentRot, OccupyingBricks);
		`Log("Number of bricks occupying the current blueprint slot location: "$OccupyingBricks.Length);
		if( OccupyingBricks.Length > 0)
		{
			foreach OccupyingBricks(Brick)
			{
				if( (Brick.Location != CurrentLoc) || (OutBrick.Rotation != CurrentRot) )
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

function GetBricksOccupyingBrickSizedLocation(vector InLocation, rotator InRotation, optional out array<DronesBrickKActor> OccupyingBricks)
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

function SpecialTraceGetAllTraceHitBricks(vector StartTraceVectorOffset, vector EndTraceVectorOffset, vector InLocation, rotator InRotation, optional out array<DronesBrickKActor> TraceHitBricks)
{
	local vector StartTraceLoc, EndTraceLoc, HitLoc, HitNorm;
	local DronesBrickKActor TraceHitBrick;
	StartTraceLoc = InLocation + (StartTraceVectorOffset >> InRotation);
	EndTraceLoc = InLocation + (EndTraceVectorOffset >> InRotation);
	foreach TraceActors(class'DronesBrickKActor', TraceHitBrick, HitLoc, HitNorm, EndTraceLoc, StartTraceLoc) 
	{
		if( TraceHitBricks.Find(TraceHitBrick) == -1 )
		{
			TraceHitBricks.AddItem(TraceHitBrick);
		}
	}
}

function bool DoesAnAvailableBrickExist()
{
	local DronesBrickKActor Brick;
	local array<DronesBrickKActor> Bricks;
	Bricks = DronesGame(WorldInfo.Game).Bricks;
	// if there are still available bricks, return TRUE, otherwise return FALSE

	foreach Bricks(Brick)
	{
		if( Brick.Availability == AVAIL_Available )
		{
			return TRUE;
		}
	}

	return FALSE;
}

function DronesBrickKActor GetClosestAvailableBrickInArray(array<DronesBrickKActor> BrickArray, vector InLoc)
{
	local DronesBrickKActor CurrentBrick;
	local float CurrentDistance;
	local DronesBrickKActor ClosestBrick;
	local float ClosestDistance;
	ClosestDistance = 100000000000;
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
	return ClosestBrick;
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
	if( vSize(Pawn.Location-PickUpBrick.Location) < 100)
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
	rand = 0;//RandRange(0,3);
	
	switch( rand )
	{
		case 0:
			`Log("Initializing random blueprint, using Cube");
			StructureBlueprint = Spawn(class'DronesStructureBlueprintCube');
			break;
		case 1:
			`Log("Initializing random blueprint, using Pyramid");
			StructureBlueprint = Spawn(class'DronesStructureBlueprintPyramid');
			break;
		case 2:
			`Log("Initializing random blueprint, using SculptureOne");
			StructureBlueprint = Spawn(class'DronesStructureBlueprintSculptureOne');
			break;
	}
	StructureBlueprint.StructureLocation.X = RandRange(-2500, 2500);
	StructureBlueprint.StructureLocation.Y = RandRange(-2500, 2500);
	
	//StructureBlueprint.StructureLocation.X = 0;
	//StructureBlueprint.StructureLocation.Y = 0;
	StructureBlueprint.StructureLocation.Z = 20;
	//StructureBlueprint.StructureRotation.Yaw = 20000;
	
	StructureBlueprint.InitializeBrickWorldLocationsAndRotationsArrays();
}

function SpawnChildDrone(DronesDrone ParentOne, DronesDrone ParentTwo)
{
	local DronesDrone ChildDrone;
	`Log("In function SpawnChildDrone");
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
	
	`Log("ParentOneController.StructureBlueprint.StructureLocation "$ParentOneController.StructureBlueprint.StructureLocation$" ParentTwoController.StructureBlueprint.StructureLocation "$ParentTwoController.StructureBlueprint.StructureLocation);
	ChildController.StructureBlueprint.StructureLocation = ParentOneController.StructureBlueprint.StructureLocation + (Normal(ParentTwoController.StructureBlueprint.StructureLocation - ParentOneController.StructureBlueprint.StructureLocation)*VSize(ParentOneController.StructureBlueprint.StructureLocation - ParentTwoController.StructureBlueprint.StructureLocation) /2);
	If( RandRange(0,100) < 100)
	{
		ChildController.StructureBlueprint.StructureLocation.X = RandRange(-2500,2500);
		ChildController.StructureBlueprint.StructureLocation.Y = RandRange(-2500,2500);
	/*
		ChildController.StructureBlueprint.StructureLocation.X += RandRange(-400,400);
		ChildController.StructureBlueprint.StructureLocation.Y += RandRange(-400,400);
	*/
	}
	`Log("ChildController.StructureBlueprint.StructureLocation "$ChildController.StructureBlueprint.StructureLocation);
	DronesStructureBluePrintMutant(ChildController.StructureBlueprint).SetBrickRelativeLocationsArray(ParentOneController.StructureBlueprint.BrickRelativeLocationsArray, ParentTwoController.StructureBlueprint.BrickRelativeLocationsArray);
	DronesStructureBluePrintMutant(ChildController.StructureBlueprint).SetBrickRelativeRotationsArray(ParentOneController.StructureBlueprint.BrickRelativeRotationsArray, ParentTwoController.StructureBlueprint.BrickRelativeRotationsArray);
	ChildController.StructureBlueprint.InitializeBrickWorldLocationsAndRotationsArrays();
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bRemovingBrick=FALSE
	bHoldingBrick=FALSE
}