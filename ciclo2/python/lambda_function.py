# Importamos el paquete de utilidades json ya que trabajaremos con un objeto JSON
import json

# Importamos el SDK de AWS (para Python el nombre del paquete es boto3)
import boto3

# Importamos time
import time

# Importamos dos paquetes para ayudarnos con las fechas y el formato de fecha

# Creamos un objeto DynamoDB usando el SDK de AWS
dynamodb = boto3.resource('dynamodb')

# Usamos el objeto DynamoDB para seleccionar nuestra tabla
table = dynamodb.Table('DN-db')

# Definimos la función manejadora que el servicio Lambda usará como punto de entrada
def lambda_handler(event, context):
  # Obtenemos la hora GMT actual
  gmt_time = time.gmtime()

  # Almacenamos la hora actual en un formato legible en una variable
  # Formateamos la cadena de tiempo GMT
  now = time.strftime('%a, %d %b %Y %H:%M:%S +0000', gmt_time)

  # Extraemos valores del objeto de evento que obtuvimos del servicio Lambda y los almacenamos en una variable
  name = event['firstName'] + ' ' + event['lastName']

  # Escribimos el nombre y la hora en la tabla DynamoDB usando el objeto que creamos y guardamos la respuesta en una variable
  response = table.put_item(
      Item={
          'ID': name,
          'LatestGreetingTime': now
      }
  )

  # Devolvemos un objeto JSON
  return {
      'statusCode': 200,
      'body': json.dumps('Hello from Lambda, ' + name)
  }
