class MiningPlayInput extends PlayerInput within MiningPlayer;

function bool InputAxis( int ControllerId, name Key, float Delta, float DeltaTime, optional bool bGamepad )
{
	
	switch(Key)
	{
	case 'MouseX':
		MiningHUD(Outer.myHUD).moveMouseX(Delta);
		Outer.mouseDragged = true;
		Outer.mousePosUpToDate = false;
		break;
	case 'MouseY':
		MiningHUD(Outer.myHUD).moveMouseY(-Delta);
		Outer.mouseDragged = true;
		Outer.mousePosUpToDate = false;
		break;
	}
	
	return false;
}

defaultproperties
{
  OnReceivedNativeInputAxis=InputAxis
}