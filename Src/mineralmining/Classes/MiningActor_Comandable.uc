class MiningActor_Comandable extends MiningActor;

struct skillInfo{
	var int			key;
	var int			cost;
	var int			costIndex;
	var float		cooldown;
	var float		castTime;
	var int			range;
	var String		skillName;
	var String 		skillDescription;
	var int 		skillButtonIndex;
	var int 		skillIcon;
	var bool		requiresTarget;
};

//1 - ICON DISABLED
//2 - ATTACK ICON
//3 - BUILD ICON
//4 - CANCEL ICON
//5 - CANCEL SPECIAL ICON
//6 - CANCEL UNIT ICON
//7 - DELIVER ICON
//8 - GO ICON
//9 - MINE ICON
//10 - REPAIR ICON
//11 - RALLY ICON
//12 - MOVE ICON

struct movementInfo{
	var Vector		position;
	var float		offset;	
};

var bool												isMoving;
var bool												isExecuting;

var float												targetDistance;
var float												totalStopTime;

var array<skillInfo>									skillsInfo;
var	skillInfo											tempSkill;

var array<movementInfo>									moves;
var movementInfo										targetPosition;

var array<delegate<skill> >								skills;
var array<delegate<preSkill> >							preSkills;
var array<int>											skillsQueue;

var(Health)	editinline int								maxHealth;
var int													currentHealth;

var(Capacity) int 										spotNBR;

var(Movement) editinline bool							canWalk;
var(Movement) editinline float							turnRate;
var(Movement) editinline float							moveSpeed;

delegate skill();
delegate preSkill();

function PostBeginPlay(){
	Super.PostBeginPlay();

	preSkills[0] = none;

	currentHealth = maxHealth;
	
	MiningGame.units.AddItem(self);

	tempSkill.key = 11;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Stop";
	tempSkill.skillDescription = "Stops the current and scheduled actions performed by this unit";
	tempSkill.skillIcon = 4;
	tempSkill.skillButtonIndex = 15;
	tempSkill.requiresTarget = FALSE;

	skillsInfo.AddItem(tempSkill);

	tempSkill.key = 25;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Move";
	tempSkill.skillDescription = "Moves the unit to a targeted location";
	tempSkill.skillIcon = 12;
	tempSkill.skillButtonIndex = 1;
	tempSkill.requiresTarget = TRUE;
	
	skillsInfo.AddItem(tempSkill);

	tempSkill.key = 10;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Interact With Unit";
	tempSkill.skillDescription = "Interacts with the targeted unit";
	tempSkill.skillIcon = 5;
	tempSkill.skillButtonIndex = -1;
	tempSkill.requiresTarget = TRUE;
	
	skillsInfo.AddItem(tempSkill);
	/*selectionEffect.Width = radius;
	selectionEffect.Height = radius;
	selectionEffect.SetHidden(true);*/
}

function Tick(float DeltaTime){
	super.Tick(DeltaTime);
	getAIController();
	update(DeltaTime);
	/*if(canWalk && MiningGame.units.Length > 2 && navController.Dest != vect(0,0,0))
		MiningPlayerOwner.ClientMessage(navController.Dest);*/	
		
	
	if(currentHealth <= 0){
		kill();
		return;
	}
	
	if(!isExecuting && skillsQueue.Length != 0){
		executeQueue();	
	}else{
		if(!isExecuting && skillsQueue.Length == 0){
			GotoState('idle');
		}
	}
}

function getAIController()
{
  local MiningAIController tempAI;
  local bool bFound;
 
  if(MiningAIOwner == none && team != MiningPlayerOwner.team){
  	foreach MiningGame.AIControllers(tempAI)
    {
    	
      if(tempAI.team == team && !bFound){
        MiningAIOwner = tempAI;
        MiningAIOwner.addAIUnit(self);
        bFound = true;
        return;
      }
    }
  }
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal){
	super.Bump(Other, OtherComp, HitNormal);
}

function update(float DeltaTime){

}

function kill(){
	MiningGame.units.RemoveItem(self);
	if(MiningAIOwner != none){
		MiningAIOwner.increaseCurrentUnitCapacity(-spotNBR);
	}else{
		MiningPlayerOwner.increaseCurrentUnitCapacity(-spotNBR);
	}
	destroy();	
}

function damage(int damageAmount){
	currentHealth -= damageAmount;
}

function addDestination(Vector position, optional float offset=0, optional int index=-1){
	local movementInfo temp;
	
	temp.position = position;
	temp.offset = offset;
	
	if(index!=-1){
		moves.InsertItem(index, temp);
	}else{
		moves.AddItem(temp);
	}
	
}

function executePreSkill(int index){
	preSkill = preSkills[index];
	preSkill();
}

function addSkillQueue(int index){
	skillsQueue.AddItem(index);
}

function executeQueue(){
	isExecuting = true;
	
	skill = skills[skillsQueue[0]];
	skillsQueue.remove(0, 1);
	skill();
}

function clearQueue(){
	super.clearQueue();
	skillsQueue.remove(0,skillsQueue.Length);
	moves.remove(0, moves.Length);
	isExecuting = false;
}

function prepareUnitMove(){
	addDestination(MiningPlayerOwner.mouseWorldLocation, 0);
}

function unitStop(){
	GotoState('idle');
	clearQueue();
}

function unitMove(){
	local Vector direction;
	
	targetPosition = moves[0];
	moves.remove(0,1);
	
	direction = (targetPosition.position - Location);
	direction.Z = 0;
	targetDistance = VSize(direction)-targetPosition.offset;
	Velocity = direction * (moveSpeed/VSize(direction));
	SetRotation(Rotator(direction));
	
	isMoving = true;
	GotoState('moving');
}

function notifyAIofDamage(){

}

state moving{
	
	function update(float DeltaTime){
		local Vector direction;
		local Vector oldLocation;
		if(isMoving && canWalk){
			if(targetDistance <= 0 || totalStopTime >= 2.0f){
				finishedMoving();
			}else{
				oldLocation = Location;
				
				direction = (targetPosition.position - Location);
				direction.Z = 0;
				targetDistance = VSize(direction)-targetPosition.offset;
				Velocity = direction * (moveSpeed/VSize(direction));
				SetRotation(Rotator(direction));
				Move(Velocity * DeltaTime);
				if(oldLocation == Location){
					totalStopTime += DeltaTime;
				}else{
					targetDistance -= VSize(Velocity * DeltaTime);	
				}
			}	
		}
	}
	
	function finishedMoving(){
		Velocity = vect(0,0,0);
		totalStopTime = 0.0f;
		isMoving = false;
		isExecuting = false;
	}
}

auto state idle{
	Begin:
		Velocity = vect(0,0,0);
		totalStopTime = 0.0f;
		isMoving = false;
		isExecuting = false;	
}

defaultproperties
{	
	canWalk = false
	turnRate = 0.0f
	moveSpeed = 0
	radius = 1000
	
	maxHealth = 0
	currentHealth = 0
	
	spotNBR = 0

	skills[0] = unitStop
	skills[1] = unitMove
	preSkills[1] = prepareUnitMove
}