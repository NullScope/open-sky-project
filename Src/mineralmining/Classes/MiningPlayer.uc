class MiningPlayer extends PlayerController;

struct subGroup{
	var array<MiningActor_Comandable>	units;
};

var int									team;
var int 								maxUnitCapacity;
var int 								currentUnitCapacity;
var array<int>							resources;

var array<MiningActor_Comandable>		selectedUnits;
var array<MiningActor>					tempSelection;
var subGroup							controlGroup[10];

var Vector 								mouseWorldLocation;
var Vector 								mouseWorldNormal;
var Vector								moveDirection;
var Vector								pointDownVec;
var Vector								xAxis;
var Vector								yAxis;

var bool								mousePosUpToDate;
var bool								mouseDragged;
var bool 								bMouseActions;
var bool								isShiftPressed;
var bool								isControlPressed;
var bool								selection;
var bool								skillPending;
var bool								gameStarted;

var int									skillPendingIndex;

var float								desiredYawChange;
var float								maxYawChangePerSec;

var MiningHUD							MiningHUD;
var MiningGameInfo						MiningGame;
var MiningActor							mouseActor;

simulated event PostBeginPlay() {
	local Rotator Rot;

	super.PostBeginPlay();
	
	MiningGame = MiningGameInfo(WorldInfo.Game);
	MiningGame.MiningPlayerController = self;

	Rot.Pitch = (-55.0f     *DegToRad) * RadToUnrRot;
	Rot.Roll =  (0          *DegToRad) * RadToUnrRot;
	Rot.Yaw =   (0.0f      *DegToRad) * RadToUnrRot;

	SetRotation(Rot);
	SetLocation(Location + vect(0,0,448));
	reComputeAxes();
	MiningCamera(PlayerCamera).setMaxZoom(Location.Z);
	gameStarted = true;
}

function traceMouse() {
	MiningHUD.getUnderMouse(mouseWorldLocation,mouseWorldNormal,mouseActor);
	mousePosUpToDate=true;
}

event PlayerTick(float DeltaTime) {
	updatePlayerPosition(DeltaTime);
	MiningHUD.updateMousePos();
	traceMouse();
}

function updatePlayerPosition(float DeltaTime) {
	if (moveDirection.X != 0 || moveDirection.Y != 0) {
		SetLocation(Location + (xAxis*moveDirection.X + yAxis*moveDirection.Y) * DeltaTime);
		mousePosUpToDate=false;
	}
}

function increaseCurrentUnitCapacity(int increase){
	currentUnitCapacity = currentUnitCapacity + increase;
}

function increaseMaxCurrentUnitCapacity(int increase){
	maxUnitCapacity = maxUnitCapacity + increase;
}

function reComputeAxes() {
	yAxis = Vector(Rotation) cross pointDownVec;
	xAxis = (yAxis cross pointDownVec)*-1;
}

function getResources(int index, int amount){
	resources[index] = resources[index]+ amount;
}

function spawnUnit(int unitTeam){
	local MiningActor_Comandable	localActor;
	local Rotator 					Rot;

	Rot.Pitch = (0.0f*DegToRad)*RadToUnrRot;
	Rot.Roll =  (0*DegToRad)* RadToUnrRot;
	Rot.Yaw =   (0.0f*DegToRad)*RadToUnrRot;
	
	localActor = Spawn(class'MiningMarine',,,mouseWorldLocation,Rot);
	
	localActor.setTeam(unitTeam);
}

function executeSkill(MiningActor_Comandable unit, int skillIndex, optional bool bClearQueue = true, optional bool bRequiresTarget = false)
{
	if(unit.skillsInfo[skillIndex].cost <= resources[unit.skillsInfo[skillIndex].costIndex]){
		if(bClearQueue){
			unit.clearQueue();
		}

		if(bRequiresTarget){
			skillPending = true;
			skillPendingIndex = skillIndex;
		}else{
			if(bClearQueue){
				skillPending = false;
				skillPendingIndex = -1;
			}
			unit.executePreSkill(skillIndex);
			unit.addSkillQueue(skillIndex);
			resources[unit.skillsInfo[skillIndex].costIndex] = resources[unit.skillsInfo[skillIndex].costIndex] - unit.skillsInfo[skillIndex].cost;
		}
	}
}

function addSelectedUnit(MiningActor_Comandable newUnit){
	
	if(selectedUnits.Find(newUnit) == -1){
		newUnit.selectUnit();
		selectedUnits.AddItem(newUnit);
		//MiningHUDReal.UpdatePortrait(newUnit.portraitTexture);
	}

}

function removeSelectedUnit(MiningActor_Comandable removeUnit){
	removeUnit.deselectUnit();
	selectedUnits.RemoveItem(removeUnit);	
}

function addTempUnit(MiningActor newUnit){
	if(tempSelection.Find(newUnit) == -1){
		newUnit.selectUnit();
		tempSelection.AddItem(newUnit);
	}
}

function removeTempUnit(MiningActor removeUnit){
	removeUnit.deselectUnit();
	tempSelection.RemoveItem(removeUnit);	
}

function setControlGroup(int group){
	controlGroup[group].units = selectedUnits;
}

function setSelectedUnits(int group){
	if(controlGroup[group].units.Length >= 0){
		clearSelection();
		selectedUnits = controlGroup[group].units;
		if(selectedUnits[0].IsA('MiningBuilding')){
			MiningHUD.scaleformHUD.changeUnitInfoFrame(2);
		}else{
			MiningHUD.scaleformHUD.changeUnitInfoFrame(1);
		}
		MiningHUD.scaleformHUD.setHUD_UnitInfo(selectedUnits[0].unitName, selectedUnits[0].currentHealth$"/"$selectedUnits[0].maxHealth);
	}
}

function clearSelection(){
	local int i;
	
	for(i = selectedUnits.Length; i > -1 ; i--){
		selectedUnits[i].deselectUnit();
		selectedUnits.Remove(i,1);
	}
}

function clearTempSelection(){
	tempSelection.Remove(0,tempSelection.Length);
}

exec function ZoomOut() {
	//local int localDistance;
	//localDistance = MiningCamera(PlayerCamera).TargetFreeCamDistance;
	
	MiningCamera(PlayerCamera).zoomOut(Location.Z);
	
	/*if(MiningCamera(PlayerCamera).TargetFreeCamDistance != localDistance){
		MiningHUD.scrollSpeed = MiningHUD.scrollSpeed + MiningCamera(PlayerCamera).TargetFreeCamDistance;
	}*/
	
	mousePosUpToDate=false;
}

exec function ZoomIn() {
	//local int localDistance;
	//localDistance = MiningCamera(PlayerCamera).TargetFreeCamDistance;
	
	MiningCamera(PlayerCamera).zoomIn(Location.Z);
	
	/*if(MiningCamera(PlayerCamera).TargetFreeCamDistance != localDistance){
		MiningHUD.scrollSpeed = MiningHUD.scrollSpeed - MiningCamera(PlayerCamera).TargetFreeCamDistance;
	}*/
	
	mousePosUpToDate=false;
}

exec function onPressLeft(){
	local int i;
	
	if(bMouseActions){
		mouseDragged = false;
	
		if(!skillPending){
			MiningHUD.startSelection();
		}else{
			if(isShiftPressed){
				for(i = 0; i < selectedUnits.Length; i++){
					executeSkill(selectedUnits[i], skillPendingIndex, false, false);
				}
			}else{
				skillPending = false;
				for(i = 0; i < selectedUnits.Length; i++){
					executeSkill(selectedUnits[i], skillPendingIndex, true, false);
				}
			}
		}
	}
}

exec function onReleaseLeft(){
	if(MiningHUD.showSelectionBox){
		MiningHUD.endSelection();
	}
}

exec function onPressRight(){
	local int i;
	
	if(bMouseActions){
		if(mouseActor == none){
			if(mousePosUpToDate){
				if(isShiftPressed){
					for(i = 0; i < selectedUnits.Length; i++){
						selectedUnits[i].addSkillQueue(1);
						selectedUnits[i].executePreSkill(1);
					}
				}else{
					for(i = 0; i < selectedUnits.Length; i++){
						selectedUnits[i].clearQueue();
						selectedUnits[i].isExecuting = false;
						selectedUnits[i].addSkillQueue(1);
						selectedUnits[i].executePreSkill(1);
					}
				}
			}
			if(MiningHUD.showSelectionBox){
				MiningHUD.endSelection();
			}
		}else{
			if(mousePosUpToDate){
				if(isShiftPressed){
					selectedUnits[i].addSkillQueue(2);
					selectedUnits[i].executePreSkill(2);
				}else{
					for(i = 0; i < selectedUnits.Length; i++){
						selectedUnits[i].clearQueue();
						selectedUnits[i].isExecuting = false;
						selectedUnits[i].addSkillQueue(2);
						selectedUnits[i].executePreSkill(2);
					}
				}
			}
		}
	}

}

exec function keyPressed(int key){
	local int i, k;

	if(gameStarted){
		switch(key){
			case 26:
				spawnUnit(team);
			break;

			case 13:
				spawnUnit(2);
			break;
		}
	
		for(i = 0; i < selectedUnits.Length; i++){
			for(k = 0; k < selectedUnits[i].skillsInfo.Length; k++){
				if(selectedUnits[i].skillsInfo[k].key == key){
					if(selectedUnits[i].skillsInfo[k].requiresTarget){
						executeSkill(selectedUnits[i], k, false, true);
					}else{
						if(isShiftPressed){
							executeSkill(selectedUnits[i], k, false, false);
						}else{
						 	executeSkill(selectedUnits[i], k, true, false);
						}
					}
				}
			}
		}
	}
}

exec function pressedNumber(int number){
	switch(number){
		case 1:
			if(isControlPressed){
				setControlGroup(1);
			}else{
				setSelectedUnits(1);
			}
		break;

		case 2:
			if(isControlPressed){
				setControlGroup(2);
			}else{
				setSelectedUnits(2);
			}
		break;
		
		case 3:
			if(isControlPressed){
				setControlGroup(3);
			}else{
				setSelectedUnits(3);
			}
		break;
		
		case 4:
			if(isControlPressed){
				setControlGroup(4);
			}else{
				setSelectedUnits(4);
			}
		break;
		
		case 5:
			if(isControlPressed){
				setControlGroup(5);
			}else{
				setSelectedUnits(5);
			}
		break;
		
		case 6:
			if(isControlPressed){
				setControlGroup(6);
			}else{
				setSelectedUnits(6);
			}
		break;
		
		case 7:
			if(isControlPressed){
				setControlGroup(7);
			}else{
				setSelectedUnits(7);
			}
		break;
		
		case 8:
			if(isControlPressed){
				setControlGroup(8);
			}else{
				setSelectedUnits(8);
			}
		break;
		
		case 9:
			if(isControlPressed){
				setControlGroup(9);
			}else{
				setSelectedUnits(9);
			}
		break;
		
		case 0:
			if(isControlPressed){
				setControlGroup(0);
			}else{
				setSelectedUnits(0);
			}
		break;
	}
}

exec function ShiftPressed(){
	isShiftPressed = true;
}

exec function ControlPressed(){
	isControlPressed = true;
}

exec function ShiftReleased(){
	isShiftPressed = false;
	if(skillPending){
		skillPending = false;
	}
}

exec function ControlReleased(){
	isControlPressed = false;
}

DefaultProperties
{
	resources[0] = 1000
	bMouseActions = true
	maxUnitCapacity = 15
	gameStarted = false
	team = 1
	pointDownVec=(X=0,Y=0,Z=-1)
	maxYawChangePerSec=90
	CameraClass=class'MiningCamera'
	InputClass=class'MiningPlayInput'
}