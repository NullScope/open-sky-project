class MiningInfantry extends MiningActor_Comandable;

var SkeletalMeshComponent			weaponMesh;

var array<MiningActor_Comandable>	targetActors;

var MiningActor_Comandable			currentTarget;

var bool							firingBurst;
var bool							firingBullet;

var(Attack) editinline bool			canFire;
var(Attack) editinline bool			canCast;
var(Attack) editinline float		attackRate;
var(Attack)	editinline int			attackBurst;
var(Attack) editinline int			attackRange;
var(Attack) editinline int			attackDamage;

var(Stances) editinline int 		defenceStanceType;

function PostBeginPlay(){
	super.PostBeginPlay();
}

function Tick(float DeltaTime){
	super.Tick(DeltaTime);

	tempSkill.key = 11;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Attack";
	tempSkill.skillDescription = "Attacks the selected enemy";
	tempSkill.skillIcon = 2;
	tempSkill.skillButtonIndex = 2;
	tempSkill.requiresTarget = FALSE;

	skillsInfo.AddItem(tempSkill);

}

function prepareUnitAttack(){
	if(MiningPlayerOwner.mouseActor.isA('MiningActor_Comandable') && MiningPlayerOwner.mouseActor != self && MiningPlayerOwner.mouseActor.team != team){
		targetActors.AddItem(MiningActor_Comandable(MiningPlayerOwner.mouseActor));
	}else{
		skillsQueue.remove(skillsQueue.Length-1,1);
		addSkillQueue(1);
		addDestination(MiningPlayerOwner.mouseActor.Location, MiningPlayerOwner.mouseActor.radius+radius);
	}
}

function unitAttack(){
	local Vector direction;

	GotoState('attacking');
		
	currentTarget = targetActors[0];
		
	targetActors.remove(0,1);
		
	targetPosition.position = currentTarget.location;
	targetPosition.offset = attackRange;
	
	direction.X = (targetPosition.position.X - Location.X);
	direction.Y = (targetPosition.position.Y - Location.Y);
	direction.Z = 0;
	
	targetDistance = VSize(direction)-targetPosition.offset;
	
	Velocity = direction * (moveSpeed/VSize(direction));
	SetRotation(Rotator(direction));
}

state attacking{
	function update(float DeltaTime){
		local Vector direction;
		
		if(currentTarget.currentHealth > 0){
		
			targetPosition.position = currentTarget.location;
			targetPosition.offset = attackRange;
	
			direction.X = (targetPosition.position.X - Location.X);
			direction.Y = (targetPosition.position.Y - Location.Y);
			direction.Z = 0;
			
			targetDistance = VSize(direction) - targetPosition.offset;
	
			Velocity = direction * (moveSpeed/VSize(direction));
			SetRotation(Rotator(direction));
			
		
			if(targetDistance <= 0){
				isMoving = false;
				Velocity = vect(0,0,0);
				fireAtEnemy();
			}else{
				isMoving = true;
				MoveSmooth(Velocity * DeltaTime);
				targetDistance -= VSize(Velocity * DeltaTime);
			}
		}else{
			Velocity = vect(0,0,0);
			isMoving = false;
			isExecuting = false;
			GotoState('idle');
		}
	}
	
	function fireAtEnemy(){
		if(!firingBurst && !isMoving){
			SetTimer(attackRate,false,'fireBurst');
			firingBurst = true;
		}
	}
}

state defending{
	function update(float DeltaTime){
		local int 								distance;
		local MiningActor_Comandable  			tempActor;
		local MiningActor_Comandable 			possibleUnit;
		local MiningBuilding 					possibleBuilding;

		possibleUnit = none;
		possibleBuilding = none;

		foreach MiningGame.units(tempActor)
		{
			distance = VSize(Location - tempActor.Location);
			if(tempActor.team != team && distance <= attackRange+200){
				// targetActors.AddItem(tempActor);
				// addSkillQueue(1);
				if(tempActor.IsA('MiningBuilding')){
					if (distance < VSize(Location - possibleUnit.Location)){
						possibleBuilding = MiningBuilding(tempActor);
					}
				}else{
					if (distance < VSize(Location - possibleUnit.Location)){
						possibleUnit = tempActor;
					}
				}
			}
		}

		if(possibleUnit == none && possibleBuilding != none){
			targetActors.AddItem(possibleBuilding);
			addSkillQueue(2);
		}else if (possibleUnit != none && possibleBuilding == none)
		{
			targetActors.AddItem(possibleUnit);
			addSkillQueue(2);
		}
	}
}

auto state idle{
	Begin:
		Velocity = vect(0,0,0);
		totalStopTime = 0.0f;
		isMoving = false;
		isExecuting = false;
		switch(defenceStanceType){
			case(1):

				GotoState('defending');
				break;
		}
}

function fireBurst(){
	local int k;
	
	if(!isMoving){
		for(k = 0; k < attackBurst; k++){
			fireBullet();
		}
	}
	
	firingBurst = false;
}

function fireBullet(){
	local MiningBullet bullet;
	local Vector bulletSpawn;
	
	weaponMesh.GetSocketWorldLocationAndRotation('fireSocket',bulletSpawn,,);
	
	bullet = Spawn(class'MiningBullet',MiningPlayerOwner,,bulletSpawn);
	
	bullet.init(currentTarget,attackDamage);
	firingBullet = false;
}

defaultproperties
{
	canWalk = true
	canFire = true
	firingBurst = false
	firingBullet = false
	
	defenceStanceType = 1;

	skills[2] = unitAttack
	preSkills[2] = prepareUnitAttack
}