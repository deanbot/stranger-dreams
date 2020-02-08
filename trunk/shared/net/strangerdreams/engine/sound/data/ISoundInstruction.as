package net.strangerdreams.engine.sound.data
{
	import flash.utils.Dictionary;

	public interface ISoundInstruction
	{
		function get key():String;
		function get musicInstructionObjects():Dictionary;
		function get ambientInstructionObjects():Dictionary;
	}
}