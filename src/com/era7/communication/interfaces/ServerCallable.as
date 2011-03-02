package com.era7.communication.interfaces
{
	import com.era7.communication.xml.Request;
	import com.era7.communication.xml.Response;
	
	public interface ServerCallable
	{
		
		/**
		 * 	Funcion para procesar las respuestas con exito a una peticion realizada al servidor
		 */
		function processSuccessfulResponse(response:Response):void;
		/**
		 * 	Funcion para procesar las respuestas erroneas a una peticion realizada al servidor
		 */
		function processErrorResponse(response:Response):void;
		/**
		 * 	Funcion para procesar cuando ha caducado la sesion cuando se realiza una peticion al servidor
		 */
		function processNoSessionResponse(response:Response):void;
		/**
		 * 	Funcion para realizar las acciones necesarias cuando se ha alcanzado el timeout de la request
		 *  especificada como parametro
		 */
		function processRequestTimeout(request:Request):void;
		
	}
}