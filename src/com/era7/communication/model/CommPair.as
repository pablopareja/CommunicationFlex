package com.era7.communication.model
{
	import com.era7.communication.interfaces.ServerCallable;
	import com.era7.communication.xml.Request;
	
	/*
	 * 	Clase necesaria ya que no existen genericos
	 */
	public class CommPair
	{
		protected var callableComp:ServerCallable = null;
		protected var request:Request = null;
		protected var timeOutSeconds:int = 0;
		
		/*
		 * 	CONSTRUCTOR
		 */
		public function CommPair(req:Request,callable:ServerCallable)
		{	
			this.callableComp = callable;
			this.request = req;
		}
		
		public function setCallableComp(value:ServerCallable):void{	this.callableComp = value; }
		public function setRequest(value:Request):void{ this.request = value; }
		public function setTimeOutSeconds(value:int):void{ this.timeOutSeconds = value; }
		
		public function getCallableComp():ServerCallable{ return this.callableComp; }
		public function getRequest():Request { return this.request; }
		public function getTimeOutSeconds():int { return this.timeOutSeconds; }
		
		public function toString():String{
			return "callable: " + callableComp + " request: " + request.toString() + " timeoutSeconds: " + timeOutSeconds;
		}

	}
}