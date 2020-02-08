package net.strangerdreams.engine.script.data
{
	import net.strangerdreams.engine.data.IFlagRequired;
	import net.strangerdreams.engine.data.IScreened;

	public interface IVersionObject extends IBaseText, IScreened, IFlagRequired
	{
		function get priority():uint;
	}
}