package net.strangerdreams.engine.item.data
{
	public interface IItem
	{
		function get key():String;
		function get title():String;
		function get description():String;
		function get assetClass():String;
		function get type():String;
	}
}