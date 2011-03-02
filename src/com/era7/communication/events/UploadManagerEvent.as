package com.era7.communication.events
{
	import com.era7.communication.xml.Request;
	import com.era7.communication.xml.Response;
	
	import flash.events.Event;

	public class UploadManagerEvent extends Event
	{
		private static const SUFIX:String = "uPMEvT";
		
		/**La subida del archivo se ha completado con exito*/
		public static const UPLOAD_COMPLETE:String = "uploadComplete" + SUFIX;
		/**Se ha cancelado la subida del archivo*/
		public static const UPLOAD_CANCELLED:String = "uploadCancelled" + SUFIX;
		/**Se produjo un error en la subida del archivo*/
		public static const UPLOAD_ERROR:String = "uploadError" + SUFIX;
		/**La peticion de subida se ha realizado*/
		public static const UPLOAD_STARTED:String = "uploadStarted" + SUFIX;		
		/**El usuario ha seleccionado el archivo que desea subir*/
		public static const FILE_SELECTED:String = "fileSelected" + SUFIX;	
		/**El usuario ha cancelado el dialogo de subida de fichero*/
		public static const BROWSE_FILE_OPERATION_CANCELLED:String = "browseFileOperationCancelled" + SUFIX;			
		
		//--------------vars-----------------
		protected var response:Response = null;
		protected var request:Request = null;
		protected var fileName:String = "";
		protected var fileSize:int = 0;
		
		/*
		 * CONSTRUCTOR
		 */
		public function UploadManagerEvent(req:Request,resp:Response,type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.request = req;
			this.response = resp;
		}
		
		
		/*
		*  Clone function
		*/
		public override function clone():Event{						
			return new UploadManagerEvent(this.request,this.response,this.type,this.bubbles,this.cancelable);
		}
		
		/*
		 * 	GET RESPONSE
		 */
		public function getResponse():Response{
			return this.response;
		}
		/*
		 * 	GET REQUEST
		 */
		public function getRequest():Request{
			return this.request;
		}
		
		/*
		 * 	GET FILE NAME
		 */
		public function getFileName():String{
			return fileName;
		}
		/*
		 * 	GET FILE SIZE
		 */
		public function getFileSize():int{
			return fileSize;
		}
		
		public function setFileName(value:String):void{	this.fileName = value;}
		public function setFileSize(value:int):void{ this.fileSize = value;	}
		
		
	}
}