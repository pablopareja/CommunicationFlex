package com.era7.communication.model
{
	import com.era7.communication.interfaces.ServerUploadable;
	import com.era7.communication.xml.Request;
	
	/*
	 * 	Clase necesaria ya que no existen genericos
	 */
	public class CommPairUpload
	{
		protected var callableComp:ServerUploadable = null;
		protected var request:Request = null;
		
		/*
		 * 	CONSTRUCTOR
		 */
		public function CommPairUpload(req:Request,callable:ServerUploadable)
		{	
			this.callableComp = callable;
			this.request = req;
		}
		
		public function setCallableComp(value:ServerUploadable):void{	this.callableComp = value; }
		public function setRequest(value:Request):void{ this.request = value; }
		
		public function getCallableComp():ServerUploadable{ return this.callableComp; }
		public function getRequest():Request { return this.request; }
		
		public function toString():String{
			return "callable: " + callableComp + " request: " + request.toString();
		}

	}
}