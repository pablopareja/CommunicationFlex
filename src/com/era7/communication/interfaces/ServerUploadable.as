package com.era7.communication.interfaces
{
	import com.era7.communication.xml.Request;
	import com.era7.communication.xml.Response;
	
	public interface ServerUploadable
	{
		
		/**
		 * Funcion para procesar las subidas de archivos completadas con exito
		 * @param response Respuesta recibida del servidor
		 * 
		 */
		function processUploadCompleted(response:Response):void;		
		/**
		 * Funcion para procesar las subidas de archivos que producieron un error
		 * @param request Peticion que produjo el error en la subida del archivo
		 * 
		 */
		function processUploadError(request:Request):void;
		/**
		 * 	Funcion llamada cuando el usuario canceló la subida por alguna razón
		 *  @param request Peticion de subida que ha sido cancelada por el usuario
		 */
		function processUploadCancelled(request:Request):void;		
		
	}
}