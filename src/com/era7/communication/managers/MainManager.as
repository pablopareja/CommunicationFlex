package com.era7.communication.managers
{
	import com.era7.communication.events.BasicManagerEvent;
	import com.era7.communication.events.UploadManagerEvent;
	import com.era7.communication.interfaces.FileBrowserListener;
	import com.era7.communication.interfaces.ServerCallable;
	import com.era7.communication.interfaces.ServerUploadable;
	import com.era7.communication.model.BasicManagerArray;
	import com.era7.communication.model.CommPair;
	import com.era7.communication.model.CommPairArray;
	import com.era7.communication.model.CommPairUpload;
	import com.era7.communication.model.CommPairUploadArray;
	import com.era7.communication.xml.Request;
	import com.era7.communication.xml.Response;
	import com.era7.util.debug.Debugger;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.FileFilter;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;

	public class MainManager extends EventDispatcher
	{
		/**
		 *  cola con las requests que se estan procesando
		 */
		protected var requestQueue:CommPairArray = null;
		
		/**
		 * 	cola con las subidas de ficheros activas
		 */
		protected var uploadRequestQueue:CommPairUploadArray = null;
		
		/**
		 * 	Array que contiene las instancias de los BasicManagers que han sido necesarios hasta el
		 *  momento segun las peticiones que se hayan realizado al servidor
		 */
		protected var managersArray:BasicManagerArray = null;
		
		/**
		 * 	Upload manager (gestiona las subidas de ficheros)
		 */
		protected var uploadManager:UploadManager = null;
		
		/**
		 * Bandera indicando si se quiere que se muestre una ventana de debug 
		 * con los xml que se estan enviando al servidor.
		 */
		public static var DEBUG_MODE:Boolean = true;
		
		/**
		 * Timeout para las peticiones en segundos
		 */
		public static var REQUEST_TIMEOUT:int = 60;		
		
		/**
		 * 	Metodo utilizado en las peticiones: POST/GET <p>
		 *  Realizar asignaciones a esta variable a traves de la clase 
		 *  URLRequestMethod.POST o URLRequestMethod.GET
		 * 
		 */
		public static var URL_REQUEST_METHOD:String = URLRequestMethod.POST;
		
		/**
		 * 	ID de sesion a incorporar en todas las peticiones
		 */
		[Bindable]
		protected static var _SESSION_ID:String = "";
		
		/**
		 * 	Bandera indicando si se debe añadir el id de sesion especificado en la variable SESSION_ID a 
		 *  todas las peticiones realizadas o no.
		 */
		public static var ADD_SESSION_ID_TO_REQUEST:Boolean = true;
		
		/**
		 * Timer para controlar el timeout de las peticiones
		 */
		protected var timeoutTimer:Timer;
		
		/**
		 * Contador para los ids de las peticiones
		 */
		protected var requestIDConunter:int = 0;
		
		private var timerStarted:Boolean = false;
		
		protected var currentBrowseListener:FileBrowserListener = null;
		
		//-----------------VARIABLES DE ESTADO--------------------
		protected var requestCounter:int = 0;		
		protected var successfulResponsesCounter:int = 0;
		protected var timeoutRequestsCounter:int = 0;
		protected var errorResponsesCounter:int = 0;
		//--------------------------------------------------------
		
		/**
		 * 	Modo de comunicacion via HTTP
		 */
		public static const HTTP_COMMUNICATION_MODE:String = BasicManager.HTTP_COMMUNICATION_MODE;
		/**
		 * 	Modo de comunicacion via Web Service
		 */
		public static const WS_COMMUNICATION_MODE:String = BasicManager.WS_COMMUNICATION_MODE;
		
		/**
		 * 	Constructor
		 */
		public function MainManager()
		{
			super();
			
			//-------------colas de peticiones------------------
			requestQueue = new CommPairArray();			
			uploadRequestQueue = new CommPairUploadArray();
			
			//------------array de managers para las peticiones--------
			managersArray = new BasicManagerArray(this);
			
			//------------gestor de subidas de ficheros---------
			uploadManager = new UploadManager(this);		
					
			timeoutTimer = new Timer(1000);
			timeoutTimer.addEventListener(TimerEvent.TIMER, onTimerComplete);	
			
			//---------------------managers array listeners-------------------------
			this.managersArray.addEventListener(BasicManagerEvent.REQUEST_COMPLETE,onRequestComplete);
			this.managersArray.addEventListener(BasicManagerEvent.REQUEST_ERROR,onRequestError);
			
			//---------------------upload manager listeners------------------------
			this.uploadManager.addEventListener(UploadManagerEvent.UPLOAD_STARTED,onUploadStarted);
			this.uploadManager.addEventListener(UploadManagerEvent.UPLOAD_CANCELLED,onUploadCancelled);
			this.uploadManager.addEventListener(UploadManagerEvent.UPLOAD_COMPLETE,onUploadComplete);
			this.uploadManager.addEventListener(UploadManagerEvent.UPLOAD_ERROR,onUploadError);
			
			this.uploadManager.addEventListener(UploadManagerEvent.FILE_SELECTED,onFileSelected);
			this.uploadManager.addEventListener(UploadManagerEvent.BROWSE_FILE_OPERATION_CANCELLED,onBrowseFileOperationCancelled);
			
			
			requestIDConunter = 0;
		}
		
		/**
		 * 	ON TIMER COMPLETE
		 */
		protected function onTimerComplete(event:TimerEvent):void {
			
			for(var i:int=0;i<requestQueue.getSize();i++){			
				
				var temp:CommPair = requestQueue.getCommPair(i);
				temp.setTimeOutSeconds(temp.getTimeOutSeconds()+1);
				
				//Debugger.appendText(temp.toString(),Debugger.ERROR_MODE);
				
				if(temp.getTimeOutSeconds() > REQUEST_TIMEOUT){					
					temp.getCallableComp().processRequestTimeout(temp.getRequest());
					requestQueue.deleteCommPairByID(temp.getRequest().getID());
					//--updating the counter----
					timeoutRequestsCounter++;
				}
			}
			
			if(requestQueue.getSize() == 0){
				timeoutTimer.reset();
			}		
			
		}
		/**
		 * 	GET REQUEST ID
		 */
		protected function getRequestID():String{
			requestIDConunter++;
			return ""+requestIDConunter;
		}
		
		/**
		 * Realiza la peticion indicada en los parametros de la funcion
		 * @param request Objeto Request que modeliza el xml concreto de la peticion a realizar
		 * @param serverCallable Objeto <i>(que implementa la interfaz ServerCallable)</i> que realiza
		 * la peticion y recibe la respuesta. 
		 * @param url Url del servicio donde se realiza la peticion
		 * @param communicationMode Via de comunicacion para realizar el servicio, una de dos opciones: 
		 * <b>
		 * 1.- MainManager.HTTP_COMMUNICATION_MODE Para peticiones HTTP tipo POST o GET
		 * 2.- MainManager.WS_COMMUNICATION_MODE Para peticiones a Web Services
		 * <b>
		 * Por defecto el tipo de comunicacion será HTTP tipo POST.
		 * 
		 */
		public function loadRequest(request:Request,
									serverCallable:ServerCallable,
									url:String,
									communicationMode:String = "HTTP_MODE"):void{
			
			if(!timeoutTimer.running){
				timeoutTimer.start();
			}
			
			//--------> Adding the session id to the request <---------
			if(ADD_SESSION_ID_TO_REQUEST){
				request.setSessionID(SESSION_ID);
			}
			
			var commPair:CommPair = new CommPair(request,serverCallable);
			requestQueue.push(commPair);
			
			managersArray.initBasicManager(url,communicationMode,URL_REQUEST_METHOD);
			var temp:BasicManager = managersArray.getBasicManagerByUrl(url);
			request.setID(this.getRequestID());
			temp.loadRequest(request);	
			
			//--updating the counter----
			requestCounter++;		
			
			if(DEBUG_MODE){
				Debugger.appendText(request.getContent().toXMLString(),Debugger.REQUEST_MODE);
			}
			
		}
		
		/**
		 * Sube un archivo con la peticion indicada en los parametros de la funcion, la subida empieza
		 * inmediatamente despues de que el usuario haya seleccionado el archivo a subir
		 * @param request Objeto Request que modeliza el xml concreto de la peticion a adjuntar a la subida del archivo
		 * @param serverUploadable Objeto <i>(que implementa la interfaz ServerUploadable)</i> que realiza
		 * la peticion y recibe la respuesta. 
		 * @param url Url del servicio donde se sube el archivo
		 * @param typeFilter Filtro de archivos a mostrar en el selector del fichero
		 * 
		 */
		public function uploadFile(request:Request,
									serverUploadable:ServerUploadable,
									url:String,
									typeFilter:FileFilter=null):void{
									
			//--------> Adding the session id to the request <---------
			if(ADD_SESSION_ID_TO_REQUEST){
				request.setSessionID(SESSION_ID);
			}
			//--------> Setting an id for the request <----------------
			request.setID(this.getRequestID());
			
			var commPairUpload:CommPairUpload = new CommPairUpload(request,serverUploadable);
			uploadRequestQueue.push(commPairUpload);
			
			//--------> Opening the dialog to select the file to be uploaded <-----
			uploadManager.startUploadOnSelectFile = true;
			uploadManager.browse(url,request,typeFilter);		
			
		}		
		/**
		 * Abre un dialogo de ficheros para subir un archivo posteriormente haciendo una llamada 
		 * explícita al método uploadBrowsedFile
		 * @param typeFilter Filtro de archivos a mostrar en el selector del fichero
		 * 
		 */
		public function browseForFileUpload(browseListener:FileBrowserListener,typeFilter:FileFilter=null):void{
			currentBrowseListener = browseListener;
			
			//--------> Opening the dialog to select the file to be uploaded <-----
			uploadManager.startUploadOnSelectFile = false;
			uploadManager.browse(null,null,typeFilter);
		}
		/**
		 * Sube un archivo con la peticion indicada en los parametros de la funcion.
		 * Para que este método funcione es imprescindible que se haya hecho una llamada previa a la función
		 * 'browseForFileUpload'
		 * @param request Objeto Request que modeliza el xml concreto de la peticion a adjuntar a la subida del archivo
		 * @param serverUploadable Objeto <i>(que implementa la interfaz ServerUploadable)</i> que realiza
		 * la peticion y recibe la respuesta. 
		 * @param url Url del servicio donde se sube el archivo 
		 * 
		 */
		public function uploadBrowsedFile(request:Request,
									serverUploadable:ServerUploadable,
									url:String):void{
			
			//--------> Adding the session id to the request <---------
			if(ADD_SESSION_ID_TO_REQUEST){
				request.setSessionID(SESSION_ID);
			}
			//--------> Setting an id for the request <----------------
			request.setID(this.getRequestID());
			
			var commPairUpload:CommPairUpload = new CommPairUpload(request,serverUploadable);
			uploadRequestQueue.push(commPairUpload);	
			
			uploadManager.uploadBrowsedFile(url,request);							
		}
		
		
		/**
		 * Activa/desactiva el modo debug de visualización de peticiones y respuestas realizadas
		 * @param value True para su activacion, false para la desactivacion.
		 * 
		 */
		public function setDebugMode(value:Boolean):void{
			DEBUG_MODE = value;
		}
		/**
		 * Setea el timeout que se tendrá en cuenta para las peticiones realizadas
		 * @param value Tiempo en segundos.
		 * 
		 */
		public function setRequestTimeout(value:int):void{
			REQUEST_TIMEOUT = value;			
		}
		
		//--------------------------------------------------------------------------------
		//-------------------------BASIC MANAGERS LISTENERS------------------------------
		//--------------------------------------------------------------------------------
		/**
		 * 	Handler para respuestas a peticiones recibidas
		 */
		protected function onRequestComplete(event:BasicManagerEvent):void{
			
			var resp:Response = event.getResponse();
			var callable:ServerCallable = this.requestQueue.getCommPairByID(resp.getID()).getCallableComp();
			
			//--updating the counter----
			successfulResponsesCounter++;
									
			if(DEBUG_MODE){
				if(resp.getStatus() == Response.STATUS_SUCCESSFUL){
					Debugger.appendText(resp.getContent().toXMLString(),Debugger.RESPONSE_MODE);
				}else if(resp.getStatus() == Response.STATUS_NO_SESSION || resp.getStatus() == Response.STATUS_ERROR){
					Debugger.appendText(resp.getContent().toXMLString(),Debugger.ERROR_MODE);
				}					
			}
			
			if(resp.getStatus() == Response.STATUS_SUCCESSFUL){
				callable.processSuccessfulResponse(resp);		
			}else if(resp.getStatus() == Response.STATUS_ERROR){
				callable.processErrorResponse(resp);	
			}else if(resp.getStatus() == Response.STATUS_NO_SESSION){
				callable.processNoSessionResponse(resp);	
			}
			
			//Borrar peticion pendiente de la cola
			var temp:Boolean = this.requestQueue.deleteCommPairByID(resp.getID());		
					
		}
		/**
		 * 	Error requests
		 */
		protected function onRequestError(event:BasicManagerEvent):void{
			this.dispatchEvent(event.clone());		
			
			//--updating the counter----
			errorResponsesCounter++;
		}
		//--------------------------------------------------------------------------------
		//--------------------------------------------------------------------------------
		
		
		//--------------------------------------------------------------------------------
		//-------------------------UPLOAD MANAGER LISTENERS------------------------------
		//--------------------------------------------------------------------------------
		/*
		*	UPLOAD STARTED
		*/
		protected function onUploadStarted(event:UploadManagerEvent):void{
			//--updating the counter----
			requestCounter++;	
			
			if(DEBUG_MODE){
				Debugger.appendText(event.getRequest().getContent().toXMLString(),Debugger.REQUEST_MODE);
			}
		}	
		/*
		*	UPLOAD COMPLETE
		*/
		protected function onUploadComplete(event:UploadManagerEvent):void{
			
			var temp:CommPairUpload = uploadRequestQueue.pop();
			temp.getCallableComp().processUploadCompleted(event.getResponse());
					
			if(DEBUG_MODE){
				Debugger.appendText(event.getResponse().getContent().toXMLString(),Debugger.RESPONSE_MODE);
			}
		}
		/*
		*	UPLOAD ERROR
		*/
		protected function onUploadError(event:UploadManagerEvent):void{
			var temp:CommPairUpload = uploadRequestQueue.pop();
			temp.getCallableComp().processUploadError(event.getRequest());
		}
		/*
		*	UPLOAD CANCELLED
		*/
		protected function onUploadCancelled(event:UploadManagerEvent):void{
			var temp:CommPairUpload = uploadRequestQueue.pop();
			temp.getCallableComp().processUploadCancelled(event.getRequest());
		}
		/*
		*	FILE SELECTED
		*/
		protected function onFileSelected(event:UploadManagerEvent):void{
			if(currentBrowseListener != null){
				currentBrowseListener.fileSelected(event.getFileName(),event.getFileSize());
			}
		}
		/*
		*	BROWSE FILE OPERATION CANCELLED
		*/
		protected function onBrowseFileOperationCancelled(event:UploadManagerEvent):void{
			if(currentBrowseListener != null){
				currentBrowseListener.browseOperationCancelled();
			}
		}
		//--------------------------------------------------------------------------------
		//--------------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------------
		//-------------------------STATE VARS GETTERS------------------------------
		public function getRequestNumber():int{return this.requestCounter;}
		public function getTimeoutRequestNumber():int{ return this.timeoutRequestsCounter;}
		public function getErrorResponseNumber():int{ return this.errorResponsesCounter;}
		public function getSuccessfulResponseNumber():int{ return this.successfulResponsesCounter;}	
		public function getBasicManagersNumber():int{ return this.managersArray.getSize();}	
		//--------------------------------------------------------------------------------
		
		public static function get SESSION_ID():String{
			return _SESSION_ID;
		}
		public static function set SESSION_ID(value:String):void{
			_SESSION_ID = value;
		}
		
		
	}
}