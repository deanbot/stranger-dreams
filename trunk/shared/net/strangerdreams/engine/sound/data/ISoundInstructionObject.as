package net.strangerdreams.engine.sound.data
{
	public interface ISoundInstructionObject
	{
		function get soundObjectKey():String;
		/*function get soundGroupType():String;*/
		function get loop():Boolean;
		function get volume():Number;
		function get nextSoundObjectKey():String;
		function get playAtStart():Boolean;
	}
}