class MiningCamera extends Camera;

var int TargetFreeCamDistance;
var int zoomAmount;
var int zoomPerSecond;
var int maxZoom;
var int minZoom;


function zoomIn(float distance) {
	TargetFreeCamDistance = FMax(TargetFreeCamDistance - zoomAmount, distance-minZoom);
}
function zoomOut(float distance) {
	TargetFreeCamDistance = FMin(TargetFreeCamDistance + zoomAmount, distance+maxZoom);
}

function correctZoom(float dt) {
	if (TargetFreeCamDistance < FreeCamDistance) {
		FreeCamDistance = FMax(FreeCamDistance - dt * zoomPerSecond, TargetFreeCamDistance);
	} else {
		FreeCamDistance = FMin(FreeCamDistance + dt * zoomPerSecond, TargetFreeCamDistance);
	}
}

function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	correctZoom(DeltaTime);
	OutVT.POV.FOV = DefaultFOV;
	OutVT.POV.Location = PCOwner.Location - Vector(PCOwner.Rotation) * FreeCamDistance;
	OutVT.POV.Rotation = PCOwner.Rotation;
	
	ApplyCameraModifiers(DeltaTime, OutVT.POV);
}

function setMaxZoom(int max)
{
	maxZoom = max;
}

function setMinZoom(int min)
{
	minZoom = min;
}
defaultproperties
{
	DefaultFOV=90.f
	TargetFreeCamDistance=448
	zoomPerSecond=30000
	zoomAmount=128
	maxZoom=0
	minZoom=896
}