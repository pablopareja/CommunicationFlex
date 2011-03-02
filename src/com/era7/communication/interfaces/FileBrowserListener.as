package com.era7.communication.interfaces
{
	public interface FileBrowserListener
	{
		
		/**
		 * Method called when the user selects a file to be uploaded
		 * @param fileName Name of the file
		 * @param fileSize File size
		 * 
		 */
		function fileSelected(fileName:String,fileSize:int):void;
		/**
		 * Method called when the user cancels the browse file dialog 
		 * 
		 */
		function browseOperationCancelled():void;
		
	}
}