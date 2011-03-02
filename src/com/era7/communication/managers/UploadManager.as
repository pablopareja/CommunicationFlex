package com.era7.communication.managers
{
	import com.era7.communication.events.UploadManagerEvent;
	import com.era7.communication.xml.Request;
	import com.era7.communication.xml.Response;
	import com.era7.util.events.CancelEvent;
	import com.era7.util.gui.window.progress.ProgressTitleWindow;
	import com.era7.util.time.TimerEstimator;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;

	/**
	 * 
	 * @author Pablo Pareja Tobes
	 * 
	 */
	public class UploadManager extends EventDispatcher
	{		
		
		protected var fileReference:FileReference = null;
		
		protected var request:Request = null;
		protected var requestUrl:String = null;
		
		//-------------------CURRENT FILE DETAILS-------------------
		protected var currentFileName:String = null;
		protected var currentFileSize:int = 0;
		protected var uploadCurrentFileEstimatedTime:Number = -1;
		//----------------------------------------------------------
				
		protected var progressWindow:ProgressTitleWindow = null;
		
		public static const XML_VERSION_LINE:String = "<?xml version='1.0' encoding='utf-8'?>";
		
		
		/**
		 *	If set to true, the upload automatically starts when the user clicks on the accept button
		 *  from the browse dialog; if not, a call to the method upload() must be explicitily done. 
		 */
		public var startUploadOnSelectFile:Boolean = true;
				
		/**
		 * 
		 * @param target 
		 * 
		 */
		public function UploadManager(target:IEventDispatcher=null)
		{
					
			super(target);
			
			fileReference = new FileReference();
			this.setUpFileReferenceListeners();
		}
		
		/**
		 * 
		 * @return Name of the file currently being uploaded
		 * 
		 */
		public function getCurrentFileName():String{
			return currentFileName;
		}
		
		/**
		 * 
		 * @return Size of the file currently being uploaded
		 * 
		 */
		public function getCurrentFileSize():int{
			return currentFileSize;
		}
			
		
		/**
		 * 	Set up file reference listeners
		 */ 
		protected function setUpFileReferenceListeners():void{
			//---------------------FILE REFERENCE LISTENERS------------------------------
			fileReference.addEventListener(Event.CANCEL, fileReferenceCancelHandler);
            fileReference.addEventListener(Event.COMPLETE, fileReferenceCompleteHandler);
	        fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, fileReferenceHttpStatusHandler);
	        fileReference.addEventListener(IOErrorEvent.IO_ERROR, fileReferenceIoErrorHandler);
	        fileReference.addEventListener(Event.OPEN, fileReferenceOpenHandler);
	        fileReference.addEventListener(ProgressEvent.PROGRESS, fileReferenceProgressHandler);
	   	    fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fileReferenceSecurityErrorHandler);
	        fileReference.addEventListener(Event.SELECT, fileReferenceSelectHandler);
	        fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,fileReferenceUploadCompleteData);
		}
		
		
		/**
		 * Opens the browse dialog
		 * @param typeFilter Files type filter
		 * 
		 */
		public function browse(url:String=null,
								req:Request=null,
								typeFilter:FileFilter=null):void{
			
			fileReference.browse([typeFilter]);
			
			if(startUploadOnSelectFile){
				this.requestUrl = url;
				this.request = req;
			}			
		}
		/**
		 * 
		 * @param url
		 * @param req
		 * @return 
		 * 
		 */
		public function uploadBrowsedFile(url:String,
								req:Request):void{
			
			this.requestUrl = url;
			this.request = req;
            
            uploadFile();
		}
		/**
		 * 
		 * 
		 */
		protected function uploadFile():void{
			
			var urlRequest:URLRequest = new URLRequest(this.requestUrl);
			var vars:URLVariables = new URLVariables();
			
            vars.request = XML_VERSION_LINE + this.request.toString();
            urlRequest.data = vars;	               
            
            initProgressTitleWindow(); 
            
            progressWindow.setFileName(currentFileName);
           	progressWindow.setFileSize(""+currentFileSize);
           	progressWindow.setEstimatedTime(uploadCurrentFileEstimatedTime);
           	
           	progressWindow.startTimer();          	
           					
           	fileReference.upload(urlRequest);
           	
           	this.dispatchEvent(new UploadManagerEvent(this.request,null,UploadManagerEvent.UPLOAD_STARTED));
		}
		//-----------------------------------------------------------------------------------
		//-------------------------FILE REFERENCE HANDLERS------------------------------------
		//-----------------------------------------------------------------------------------		
		/*
		*	CANCEL
		*/	
		protected function fileReferenceCancelHandler(event:Event):void{
			if(this.startUploadOnSelectFile){
				this.dispatchEvent(new UploadManagerEvent(this.request,null,UploadManagerEvent.UPLOAD_CANCELLED));
			}else{
				this.dispatchEvent(new UploadManagerEvent(this.request,null,UploadManagerEvent.BROWSE_FILE_OPERATION_CANCELLED));
			}
			
		}	
		/*
		*	UPLOAD COMPLETE DATA
		*/	
		protected function fileReferenceUploadCompleteData(event:DataEvent):void{
			progressWindow.setUploadCompleted();
			var response:Response = new Response(String(event.data));
			this.dispatchEvent(new UploadManagerEvent(this.request,response,UploadManagerEvent.UPLOAD_COMPLETE));
		}		
		/*
		*	COMPLETE
		*/	
		protected function fileReferenceCompleteHandler(event:Event):void{}	
		/*
		*	HTTP STATUS
		*/		
		protected function fileReferenceHttpStatusHandler(event:HTTPStatusEvent):void{
			progressWindow.setErrorState();
			this.dispatchEvent(new UploadManagerEvent(this.request,null,UploadManagerEvent.UPLOAD_ERROR));
		}
		/*
		*	IO ERROR
		*/	
		protected function fileReferenceIoErrorHandler(event:IOErrorEvent):void{
			progressWindow.setErrorState();
			this.dispatchEvent(new UploadManagerEvent(this.request,null,UploadManagerEvent.UPLOAD_ERROR));
		}
		/*
		*	OPEN
		*/	
		protected function fileReferenceOpenHandler(event:Event):void{}
		/*
		*	SECURITY ERROR
		*/	
		protected function fileReferenceSecurityErrorHandler(event:SecurityErrorEvent):void{
			progressWindow.setErrorState();
			this.dispatchEvent(new UploadManagerEvent(this.request,null,UploadManagerEvent.UPLOAD_ERROR));
		}
		/*
		*	SELECT
		*/		
		protected function fileReferenceSelectHandler(event:Event):void{		           
            
            currentFileName = fileReference.name;
            currentFileSize = Math.ceil(fileReference.size/1024);
            uploadCurrentFileEstimatedTime = TimerEstimator.estimateUploadTime(fileReference.size,8);
            
            //Alert.show("fileName: " + currentFileName + "\nfileSize: " + currentFileSize +
            //			"\nestimatedTime: " + uploadCurrentFileEstimatedTime);
            
            if(startUploadOnSelectFile){
            	uploadFile();
            }      
            
            var tempEvent:UploadManagerEvent = new UploadManagerEvent(this.request,null,UploadManagerEvent.FILE_SELECTED,true);
            tempEvent.setFileName(currentFileName);
            tempEvent.setFileSize(currentFileSize);
            this.dispatchEvent(tempEvent);           
           	   
		}
		/*
		*	PROGRESS
		*/		
		protected function fileReferenceProgressHandler(event:ProgressEvent):void{
			
		}	
		//-----------------------------------------------------------------------------------
		//-----------------------------------------------------------------------------------
		
		/*
		*	INIT WINDOW
		*/	
		protected function initProgressTitleWindow():void{
			
			if(this.progressWindow == null){
				
				progressWindow = ProgressTitleWindow(PopUpManager.createPopUp(UIComponent(FlexGlobals.topLevelApplication),ProgressTitleWindow,true));
				PopUpManager.centerPopUp(progressWindow);
			
				progressWindow.addEventListener(CancelEvent.CANCEL_PRESSED,onProgressWindowCancelPressed);
			}
			
			//progressWindow.showCloseButton = false;
			progressWindow.init();     
			PopUpManager.bringToFront(this.progressWindow);
			this.progressWindow.visible = true;
			
		}
		protected function onProgressWindowCancelPressed(event:CancelEvent):void{
			fileReference.cancel();
			this.dispatchEvent(new UploadManagerEvent(this.request,null,UploadManagerEvent.UPLOAD_CANCELLED));						
		}
			
		
	}
}