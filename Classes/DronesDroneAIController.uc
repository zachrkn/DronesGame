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


//==========================EVENTS==========================================
event Possess( Pawn inPawn, bool bVehicleTransition)
{
//	local vector v;

	super.Possess(inPawn, bVehicleTransition);
}

//==========================STATES==========================================
auto state Idle
{
	local DronesBrickKActor Brick;
	local DronesDrone Drone;
	event Tick (float DeltaTime)
    {
		EveryTickStuff();
		
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
	local StaticMeshComponent ThisStaticMeshComponent;
	local int i;
	local DronesBrickConstraint Constraint;
	local DronesBrickKActor OtherConstrainedBrick;

	event Tick (float DeltaTime)
	{
		EveryTickStuff();	
		
		// check to make sure the brick is still available; if it's not, go back to idle
		if ( PickUpBrick.Availability != AVAIL_Available )
		{
			GotoState('Idle');
		}
		
		// if the Drone reaches the brick, disappear the brick, make it unavailable, and pick an unoccupied brick location to place the held brick
		if ( IsPawnAtTargetBrick())
		{
			//`Log("In state GetBrick, checking to see if there is an empty blueprint location, and to set DropLocation");
			if( GetFirstEmptyBlueprintLocationAndRotation(StructureBlueprint, DropLocation, DropRotation) )
			{	
				PickUpBrick = GetClosestAvailableBrickInArray( DronesGame(WorldInfo.Game).Bricks, Pawn.Location );
			
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
	local StaticMeshComponent ThisStaticMeshComponent;
	local bool bSpawnChildDrone;

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
				PickUpBrick.Availability = AVAIL_Available;
				
				`Log("Dropped PickUpBrick.  PickUpBrick.Location: "$PickUpBrick.Location$" and PickUpBrick.Rotation: "$PickUpBrick.Rotation);
				
				//PickUpBrick.CreateConstraintWithBrick(AdjacentBrick); // shouldn't need this because next line should include adjacent brick
				//PickUpBrick.CreateConstraintWithAllTouchingBricks();
												
				// make the brick available
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

function bool IsBrickSizedLocationOccupied(vector InLocation, rotator InRotation)
{
	local DronesBrickLocationTester BrickTester;
	local bool bOverlap;
	
	BrickTester = Spawn(class'DronesBrickLocationTester',,,InLocation,InRotation,,);
	bOverlap = BrickTester.DoesBrickOverlap();
	BrickTester.Destroy();
	//`Log("In function IsBrickSizedLocationOccupied, the answer is "$bOverlap);
	return bOverlap;
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
	rand = RandRange(0,2);
	
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
	If( RandRange(0,100) < 50)
	{
		ChildController.StructureBlueprint.StructureLocation.X + RandRange(-400,400);
		ChildController.StructureBlueprint.StructureLocation.Y + RandRange(-400,400);
	}
	`Log("ChildController.StructureBlueprint.StructureLocation "$ChildController.StructureBlueprint.StructureLocation);
	DronesStructureBluePrintMutant(ChildController.StructureBlueprint).SetBrickRelativeLocationsArray(ParentOneController.StructureBlueprint.BrickRelativeLocationsArray, ParentTwoController.StructureBlueprint.BrickRelativeLocationsArray);
	DronesStructureBluePrintMutant(ChildController.StructureBlueprint).SetBrickRelativeRotationsArray(ParentOneController.StructureBlueprint.BrickRelativeRotationsArray, ParentTwoController.StructureBlueprint.BrickRelativeRotationsArray);
	ChildController.StructureBlueprint.InitializeBrickWorldLocationsAndRotationsArrays();
}

/*
function DronesBrickKActor GetARandomAvailableBrick()
{
	local DronesBrickKActor Brick;
	local int Index;
	local array<DronesBrickKActor> Bricks;
	Bricks = DronesGame(WorldInfo.Game).Bricks;
	
	// get a random brick
	Index = RandRange(0, Bricks.Length);
	Brick = Bricks[Index];

	return Brick;
}

function SetDropLocationAndGoToDropState()
{
	if( ShouldDropLocationBeAdjacentToABrick() && DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist())
	{
		//`Log("Selecting a destination location that is adjacent to a brick");
		AdjacentBrick = GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation(0);
		AdjacentBrickSocketNumber = GetRandomUnoccupiedSocketNumberFromBrick(AdjacentBrick);
		GotoState('PlaceBrickAdjacentToBrick');
	}
	else
	{
		//`Log("Getting a random target destination");
		SetRandomDropLocationAndRotationWithinDestinationRange(DropLocation, DropRotation);
		GotoState('PlaceBrickAtDropLocation');
	}
}

function bool ShouldDropLocationBeAdjacentToABrick()
{
	if( RandRange(0,100) < ProbabilityForDropLocationToBeAdjacentToABrick ) 
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function bool ShouldTargetBrickAttachToAdjacentBrick()
{
	if( RandRange(0,100) < ProbabilityForAttachingPickUpBrickToAdjacentBrick ) 
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function SetRandomDropLocationAndRotationWithinDestinationRange(out vector TargetVector, out rotator TargetRotation)
{	
	local bool bOccupied;
	
	TargetVector.X = DestinationRangeCenter.X + (RandRange(0,DestinationRangeSize.X)-(DestinationRangeSize.X/2));
	TargetVector.Y = DestinationRangeCenter.Y + (RandRange(0,DestinationRangeSize.Y)-(DestinationRangeSize.Y/2));
	TargetVector.Z = DestinationRangeCenter.Z + (RandRange(0,DestinationRangeSize.Z)-(DestinationRangeSize.Z/2));
	TargetRotation.Pitch = RandRange(0, 65556);
	TargetRotation.Yaw = RandRange(0, 65556);	
	TargetRotation.Roll = RandRange(0, 65556);
	
	//`Log("in function GetUnoccupiedRandomTargetDestinationWithinDestinationRange calling function IsBrickSizedLocationOccupied");
	bOccupied = IsBrickSizedLocationOccupied(TargetVector,TargetRotation);
	if( (bOccupied || (TargetVector.Z < -1.5)))
	{
		SetRandomDropLocationAndRotationWithinDestinationRange(TargetVector, TargetRotation);
	}
}

function bool DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist()
{
	local DronesBrickKActor Brick;
	local array<DronesBrickKActor> Bricks;
	
	Bricks = DronesGame(WorldInfo.Game).Bricks;
	
	//`Log("In function DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist");
	if ( DoesAnAvailableBrickWithinDestinationRangeExist() )
	{
		foreach Bricks(Brick)
		{
			if( Brick.Availability == AVAIL_Available )
			{
				if( IsVectorWithinDestinationRange(Brick.Location) )
				{
					//`Log("Drone "$Pawn$" In function DoesAnAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocationExist, running through foreach brick, and checking to see if there is one with an unoccupied socket location");
					// if this brick has a socket with an occupied location that is above ground
					if( IsThereAnUnoccupiedSocketOnBrick(Brick) )
					{
						return TRUE;
					}
				}
			}
		}
	}

	return FALSE;
}

function DronesBrickKActor GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation(int RecursionDepth)
{
	local DronesBrickKActor Brick;
	local array<DronesBrickKActor> Bricks;
	
	Bricks = DronesGame(WorldInfo.Game).Bricks;
	if( RecursionDepth > 50)
	{
		foreach Bricks(Brick)
		{
			if( Brick.Availability == AVAIL_Available )
			{
				//`Log("Drone "$Pawn$" in function GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation, going through foreach brick "$AvailableBrick$" checking to see if there is one with an unoccupied socket location");
				if( IsThereAnUnoccupiedSocketOnBrick(Brick) )
				{
					return Brick;
				}
			}
		}
	}
	else
	{
		Brick = GetRandomAvailableBrickWithinDestinationRange(0);
		if( !IsThereAnUnoccupiedSocketOnBrick(Brick) )
		{
			Brick = GetRandomAvailableBrickWithinDestinationRangeThatHasAnUnoccupiedSocketLocation(RecursionDepth);
		}
		return Brick;
	}
}

function bool DoesAnAvailableBrickWithinDestinationRangeExist()
{
	local DronesBrickKActor TempBrick;
	local array<DronesBrickKActor> Bricks;
	
	//`Log("In function DoesAnAvailableBrickWithinDestinationRangeExist");
	Bricks = DronesGame(WorldInfo.Game).Bricks;
	
	foreach Bricks(TempBrick)
	{
		if( TempBrick.Availability == AVAIL_Available)
		{
			if(IsVectorWithinDestinationRange(TempBrick.Location))
			{
				//`Log("Going to return true, that a brick within destination range exists");
				return TRUE;
			}
		}
	}
	//`Log("Going to return false, that a brick within destination range does NOT exist");
	return FALSE;
}

function DronesBrickKActor GetRandomAvailableBrickWithinDestinationRange(int RecursionDepth)
{
	local int BrickIndex;
	local DronesBrickKActor TempBrick;
	local array<DronesBrickKActor> Bricks;
	local int i;
	local bool bFound;

	bFound = FALSE;
	RecursionDepth += 1;
	Bricks = DronesGame(WorldInfo.Game).Bricks;
	
	//`Log("Drone: "$Pawn$" Before doing anything, RecursionDepth: "$RecursionDepth);
	if (RecursionDepth < 50)
	{
		//`Log("RecursionDepth less than 50");
		BrickIndex = RandRange(0,Bricks.Length-1);
		TempBrick = Bricks[BrickIndex];
		//`Log("Got a new brick from the AvailableBricks array. TempBrick: "$TempBrick);
		if(!IsVectorWithinDestinationRange(TempBrick.Location))
		{
			//`Log("But that brick is out of destination range, so I'm going to do a recursive call to this function");
			TempBrick = GetRandomAvailableBrickWithinDestinationRange(RecursionDepth);
			//`Log("Returned out of recursive call");
		}
	}
	else
	{
		//`Log("RecursionDepth greater than 50");
		for (i=0; (i<Bricks.Length) && !bFound; i++)
		{
			TempBrick = Bricks[i];
			//`Log("Got a new brick from AvailableBricks aray: "$TempBrick);
			if(IsVectorWithinDestinationRange(TempBrick.Location))
			{
				bFound=TRUE;
			}
		}
	}

	//`Log("Returning TempBrick "$TempBrick);
	return TempBrick;
	
}

function bool IsVectorWithinDestinationRange(vector InVector)
{
	local bool bXWithinRange, bYWithinRange, bZWithinRange;
	bXWithinRange = FALSE; bYWithinRange = FALSE; bZWithinRange = FALSE;
	
	if(	(InVector.X > (DestinationRangeCenter.X-(DestinationRangeSize.X/2))) && (InVector.X < (DestinationRangeCenter.X+(DestinationRangeSize.X/2))) )
	{
		bXWithinRange = TRUE;
	}
	if(	(InVector.Y > (DestinationRangeCenter.Y-(DestinationRangeSize.Y/2))) && (InVector.Y < (DestinationRangeCenter.Y+(DestinationRangeSize.Y/2))) )
	{
		bYWithinRange = TRUE;
	}
	if(	(InVector.Z > (DestinationRangeCenter.Z-(DestinationRangeSize.Z/2))) && (InVector.Z < (DestinationRangeCenter.Z+(DestinationRangeSize.Z/2))) )
	{
	
		bZWithinRange = TRUE;
	}
	
	if (bXWithinRange && bYWithinRange && bZWithinRange)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

function bool IsThereAnUnoccupiedSocketOnBrick(DronesBrickKActor InBrick)
{
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	local vector SocketLocation;
	local int i;
	local bool bIsThereAnUnoccupiedSocketLocation;
	
	bIsThereAnUnoccupiedSocketLocation = FALSE;
	
	foreach InBrick.ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		for (i=1; i<7 && !bIsThereAnUnoccupiedSocketLocation; i++)
		{
			SocketLocation = GetSocketWorldLocationFromNumberAndComponent(i, ThisSkeletalMeshComponent);
			
			//`Log("Drone "$Pawn$" in function IsThereAnUnoccupiedSocketOnBrick with InBrick "$InBrick$" i "$i$" SocketLocation.Z "$SocketLocation.Z);
			if( SocketLocation.Z > 1.5 )
			{
				//`Log("Drone "$Pawn$" in function IsThereAnUnoccupiedSocketOnBrick calling function IsBrickSizedLocationOccupied with InBrick "$InBrick);
				if( !IsBrickSizedLocationOccupied(SocketLocation, InBrick.Rotation) )
				{
					//`Log("Drone "$Pawn$" in function IsThereAnUnoccupiedSocketOnBrick, and returning that the following socket location is unoccupied: "$i$" with InBrick "$InBrick);
					bIsThereAnUnoccupiedSocketLocation = TRUE;
				}
			}
		}
	}
	//`Log("in function IsThereAnUnoccupiedSocketOnBrick, with InBrick "$InBrick$" returning "$bIsThereAnUnoccupiedSocketLocation);
	return bIsThereAnUnoccupiedSocketLocation;
}

function int GetRandomUnoccupiedSocketNumberFromBrick(DronesBrickKActor InBrick)
{	
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	local Vector SocketLocation;
	local int SocketNum;
	
	foreach InBrick.ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		SocketNum = RandRange(1,7);
		SocketLocation = GetSocketWorldLocationFromNumberAndComponent(SocketNum, ThisSkeletalMeshComponent);
	}
	
	//`Log("Drone "$Pawn$" in function GetRandomUnoccupiedSocketNumberFromBrick calling function IsBrickSizedLocationOccupied with the Brick "$InBrick$" location of socket "$SocketNum$" which is at location "$SocketLocation);
	// if the return vector would be below ground, or the return vector is occupied, get a new socket
	if ( (SocketLocation.Z < -1.5) || IsBrickSizedLocationOccupied(SocketLocation, InBrick.Rotation) )
	{
		//`Log("Drone "$Pawn$" in function GetRandomUnoccupiedSocketNumberFromBrick doing a recursive call.  SocketLocation.Z "$SocketLocation.Z$" and i used socket "$SocketNum);
		SocketNum = GetRandomUnoccupiedSocketNumberFromBrick(InBrick);
	}
	
	return SocketNum;
}

function vector GetSocketWorldLocationFromNumberAndComponent(int SocketNum, SkeletalMeshComponent InSMComp)
{
	local vector SocketLocation;
	switch( SocketNum )
	{
		case 1:
			InSMComp.GetSocketWorldLocationAndRotation('Socket01', SocketLocation);
			break;
		case 2:
			InSMComp.GetSocketWorldLocationAndRotation('Socket02', SocketLocation);
			break;
		case 3:
			InSMComp.GetSocketWorldLocationAndRotation('Socket03', SocketLocation);
			break;
		case 4:
			InSMComp.GetSocketWorldLocationAndRotation('Socket04', SocketLocation);
			break;
		case 5:
			InSMComp.GetSocketWorldLocationAndRotation('Socket05', SocketLocation);
			break;
		case 6:
			InSMComp.GetSocketWorldLocationAndRotation('Socket06', SocketLocation);
			break;
	}
	return SocketLocation;
}
*/

//==========================DELEGATES==========================================
delegate int SortBricksRandomly(DronesBrickKActor BrickA, DronesBrickKActor BrickB)
{
	if(RandRange(0,1) < 0.5)
	{
		return -1;
	}
	else
	{
		return 1;
	}
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bHoldingBrick=FALSE
}