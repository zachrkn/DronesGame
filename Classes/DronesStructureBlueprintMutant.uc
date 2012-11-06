//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintMutant extends DronesStructureBlueprint;

//==========================FUNCTIONS==========================================
function SetBrickRelativeLocationsArray(array<vector> ParentOneRelLocArray, array<vector> ParentTwoRelLocArray)
{
	local int NewArrayLength;
	local int ArrayLengthDiff;
	local int i;
	local vector Halfway;	
	local float FullDistance, HalfwayDistance;
	
	`Log("In function SetBrickRelativeLocationsArray");
	ArrayLengthDiff = Abs(ParentOneRelLocArray.Length - ParentTwoRelLocArray.Length);
	`Log("Difference between length of two arrays "$ArrayLengthDiff);
	if( ParentOneRelLocArray.Length <= ParentTwoRelLocArray.Length )
	{
		`Log("Parent one's array was shorter, or they were the same legth");
		NewArrayLength = ParentOneRelLocArray.Length + ArrayLengthDiff;
		for( i=0; i<NewArrayLength; i++)
		{
			if( i>=ParentOneRelLocArray.Length )
			{
				BrickRelativeLocationsArray[i] = ParentTwoRelLocArray[i];
				`Log("i is greater than or equal to parent one (the shorter array)'s length, so i'm going to set location to parent two's location "$BrickRelativeLocationsArray[i]);
			}
			else
			{
				FullDistance = VSize(ParentOneRelLocArray[i] - ParentTwoRelLocArray[i]);
				HalfwayDistance = FullDistance / 2;
				Halfway = (ParentOneRelLocArray[i] + Normal(ParentTwoRelLocArray[i] - ParentOneRelLocArray[i])*HalfwayDistance);
				BrickRelativeLocationsArray[i] = Halfway;
				`Log("ParentOneLocation "$ParentOneRelLocArray[i]$" and ParentTwoLocation "$ParentTwoRelLocArray[i]$" and child location "$BrickRelativeLocationsArray[i]);
			}
		}
	}
	else
	{
		`Log("Parent two's array was shorter");
		NewArrayLength = ParentTwoRelLocArray.Length + ArrayLengthDiff;
		for( i=0; i<NewArrayLength; i++)
		{
			if( i>=ParentTwoRelLocArray.Length )
			{
				BrickRelativeLocationsArray[i] = ParentOneRelLocArray[i];
				`Log("i is greater than or equal to parent two (the shorter array)'s length, so i'm going to set location to parent two's location "$BrickRelativeLocationsArray[i]);
			}
			else
			{
				FullDistance = VSize(ParentOneRelLocArray[i] - ParentTwoRelLocArray[i]);
				HalfwayDistance = FullDistance / 2;
				Halfway = (ParentOneRelLocArray[i] + Normal(ParentTwoRelLocArray[i] - ParentOneRelLocArray[i])*HalfwayDistance);
				BrickRelativeLocationsArray[i] = Halfway;
				`Log("ParentOneLocation "$ParentOneRelLocArray[i]$" and ParentTwoLocation "$ParentTwoRelLocArray[i]$" and child location "$BrickRelativeLocationsArray[i]);
			}
		}
	}
	
	if( RandRange(0,100) < 25)
	{
		for( i=0; i<BrickRelativeLocationsArray.Length; i++)
		{
			if( RandRange(0,100) < 15)
			{
				BrickRelativeLocationsArray[i].X + RandRange(-50,50);
				BrickRelativeLocationsArray[i].Y + RandRange(-50,50);
			}
		}
	}
}

function SetBrickRelativeRotationsArray(array<rotator> ParentOneRelRotArray, array<rotator> ParentTwoRelRotArray)
{
	local int i;
	local rotator r;
	r.Pitch = 0; r.Yaw = 0; r.Roll = 0;
	for (i=0; i<45; i++)
	{
		BrickRelativeRotationsArray[i] = r;
	}
}