class MiningGameInfo extends GameInfo;

var array<MiningActor_Comandable>			units;
var array<MiningResource>					resources;
var array<MiningAIController> 				AIControllers;
var MiningPlayer 							MiningPlayerController;

function PostBeginPlay()
{
	super.PostBeginPlay();
	Spawn(class'MiningAIController',,,vect(0,0,1000));
}

function Tick(float DeltaTime)
{
	local MiningAIController 		tempAI;
	local MiningActor_Comandable 	tempUnit;
	local int 					unitNumbers;
	super.Tick(DeltaTime);

	if(MiningPlayerController.gameStarted){
		foreach AIControllers(tempAI)
		{
			foreach units(tempUnit)
			{
				if(tempUnit.team == tempAI.team){
					unitNumbers = unitNumbers + 1;
				}
			}

			if(unitNumbers == 0){
				MiningPlayerController.MiningHUD.scaleformHUD.showVictory();
			}
			unitNumbers = 0;

			foreach units(tempUnit)
			{
				if(tempUnit.team == MiningPlayerController.team){
					unitNumbers = unitNumbers + 1;
				}
			}

			if(unitNumbers == 0){
				MiningPlayerController.MiningHUD.scaleformHUD.showDefeat();
			}
		}
	}

}

defaultproperties
{
	PlayerControllerClass = class'MiningPlayer'
	HUDType = class'MiningHUD'
	bRestartLevel = false
}