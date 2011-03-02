package com.era7.communication.managers
{
	import com.era7.communication.events.BasicManagerEvent;
	import com.era7.communication.xml.Request;
	import com.era7.communication.xml.Response;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.LoadEvent;
	import mx.rpc.soap.WebService;

	public class BasicManager extends EventDispatcher
	{
		//---Variables necesarias para la comunicacion via http(s) con el servidor--
		protected var urlVariables:URLVariables;
		protected var urlRequest:URLRequest = null;
		protected var urlLoader:URLLoader = null;
		protected var url:String = "";
		//-----------------------------------------------------------------------------		
		
		//---Variables necesarias para la comunicacion via WS con el servidor-----
		protected var webService:WebService = null;
		protected var wsLoaded:Boolean = false;
		//-----------------------------------------------------------------------------	
		
		//--------------------Modos de comunicacion con el servidor-------------------
		protected var communicationMode:String = HTTP_COMMUNICATION_MODE;
		public static const WS_COMMUNICATION_MODE:String = "WS_MODE";
		public static const HTTP_COMMUNICATION_MODE:String = "HTTP_MODE";
		//---------------------------------------------------------------------------
		
		public static const DEFAULT_URL_REQUEST_METHOD:String = URLRequestMethod.POST;
				
		public static const XML_VERSION_LINE:String = "<?xml version='1.0' encoding='utf-8'?>";
		
		
		
		/**
		 * Definicion del timeout en milisegundos tras el cual se corta la comunicacion con 
		 * el servidor y se lanza un evento del tipo ServerResponseEvent.COMMUNICATION_TIMEOUT
		 */
		protected var TIMEOUT_VALUE:Number = 60000;
		
		/**
		 * Metodo utilizado en la peticion al servidor--> GET o POST (POST por defecto)
		 */
		protected var requestHttpMethod:String = URLRequestMethod.POST;
		/**
		 * 	Cola de peticiones
		 */
		protected var requestQueue:Array = null;
		
		
		/**
		 * 	Constructor 
		 */
		public function BasicManager(urlValue:String,
									mainManager:MainManager,
									communicationModeValue:String = HTTP_COMMUNICATION_MODE,
									urlRequestMethod:String = DEFAULT_URL_REQUEST_METHOD)
		{
			super(mainManager);
			
			this.requestQueue = new Array();
			
			this.url = urlValue; 
			
			this.communicationMode = communicationModeValue;
			
			if(communicationMode == HTTP_COMMUNICATION_MODE){
				
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);				
				
				urlRequest = new URLRequest(url);
				urlRequest.method = requestHttpMethod;	
				
			}else if(communicationMode == WS_COMMUNICATION_MODE){
				
				webService = new mx.rpc.soap.WebService();
				webService.wsdl = this.url;
				
				webService.addEventListener(LoadEvent.LOAD, onLoadWS);
                webService.addEventListener(ResultEvent.RESULT, onResultWS);
                webService.addEventListener(FaultEvent.FAULT, onFaultWS);
                
				webService.loadWSDL();
				
			}				
			
		}
		
		//---------------------------------------------------------------------------------------
		//-------------------------HTTP COMMUNICATION MODE EVENT HANDLERS------------------------
		//---------------------------------------------------------------------------------------
		
		/**
		 * 	Metodo llamado cuando se produce un error de IO al realizar la peticion
		 */
		protected function ioErrorHandler(event:IOErrorEvent):void {	
			Alert.show(event.toString());
			this.dispatchEvent(new BasicManagerEvent(null,BasicManagerEvent.REQUEST_ERROR,true));
						
			//Quitamos la peticion que se acaba de resolver
			requestQueue.pop()
			
			if(requestQueue.length > 0){
				var req:Request = Request(requestQueue.pop());				
				doRequest(req);
			}
		}		
		/**
		 * 	On complete
		 */
		protected function onComplete(event:Event):void{		
									
			var response:Response = new Response(XML(event.target.data));	
			this.dispatchEvent(new BasicManagerEvent(response,BasicManagerEvent.REQUEST_COMPLETE,true));		
						
			//Quitamos la peticion que se acaba de resolver
			requestQueue.pop()		
			
			//Si quedan peticiones pendientes se extraen y se hacen
			if(requestQueue.length > 0){
				var req:Request = Request(requestQueue.pop());				
				doRequest(req);
			}					
				
		}
		//---------------------------------------------------------------------------------------		
		//---------------------------------------------------------------------------------------
		
		//---------------------------------------------------------------------------------------
		//---------------------WEB SERVICE COMMUNICATION MODE EVENT HANDLERS---------------------
		//---------------------------------------------------------------------------------------
		/**
		 * 	ON FAULT WS
		 */
		protected function onFaultWS(event:FaultEvent):void {	
			this.dispatchEvent(new BasicManagerEvent(null,BasicManagerEvent.REQUEST_ERROR,true));
						
			//Quitamos la peticion que se acaba de resolver
			requestQueue.pop()
			
			if(requestQueue.length > 0){
				var req:Request = Request(requestQueue.pop());				
				doRequest(req);
			}
		}		
		/**
		 * 	ON COMPLETE WS
		 */
		protected function onResultWS(event:ResultEvent):void{					
									
			var response:Response = new Response(XML(event.result));	
			this.dispatchEvent(new BasicManagerEvent(response,BasicManagerEvent.REQUEST_COMPLETE,true));		
						
			//Quitamos la peticion que se acaba de resolver
			requestQueue.pop()		
			
			//Si quedan peticiones pendientes se extraen y se hacen
			if(requestQueue.length > 0){
				var req:Request = Request(requestQueue.pop());				
				doRequest(req);
			}					
				
		}
		/**
		 * 	ON LOAD WS
		 */
		protected function onLoadWS(event:LoadEvent):void{
			wsLoaded = true;
			
			if(requestQueue.length > 0){
				while(requestQueue.length > 0){
					this.loadRequest(Request(requestQueue.pop()));
				}
			} 
		}		
		//---------------------------------------------------------------------------------------		
		//---------------------------------------------------------------------------------------
		
		
		/**
		 * 	GET URL
		 */
		public function getUrl():String{
			return this.url;
		}
		/**
		 * 	SET URL
		 */
		public function setUrl(value:String):void{
			this.url = value;
			this.urlRequest.url = this.url;
		}
		
		/**
		 * 	GET COMMUNICATION MODE
		 */
		public function getCommunicationMode():String{
			return this.communicationMode;
		}
		
		
		/**
		 * 	Load request
		 */
		public function loadRequest(request:Request):void{				
			
			if(this.communicationMode == HTTP_COMMUNICATION_MODE){
				
				if(requestQueue.length == 0){
					doRequest(request);			
				}else{
					requestQueue.splice(0,0,request);		
				}
				
			}else if(this.communicationMode == WS_COMMUNICATION_MODE){
				
				if(wsLoaded){
					var tempOperation:AbstractOperation = webService.getOperation(request.getMethod());
					//----IMPORTANTE!!! 
					//--> SI SE CAMBIASE EL NOMBRE DE LA VARIABLE SOBRE LA QUE VA EL XML DE LA PETICION
					//HABRIA QUE CAMBIAR A MANO ESTA LINEA Y RECOMPILAR
					tempOperation.arguments.request = request.toString();
					tempOperation.send(request);
				}else{
					requestQueue.splice(0,0,request);
				}				
			}
						
			
		}	
		
		private function doRequest(req:Request):void{
			urlVariables = new URLVariables();
			urlVariables.request = XML_VERSION_LINE+req.getContent().toXMLString();
			urlRequest.data = urlVariables;	
			
			urlLoader.load(urlRequest);				
			requestQueue.push(req);
			
		}	
		
	}
}