package {
	// returns a random number between specified range (inclusive)
	public function randRange(min:int, max:int):int {
	    var randomNum:int = Math.floor(Math.random() * (max - min + 1)) + min;
	    return randomNum;
	}
}