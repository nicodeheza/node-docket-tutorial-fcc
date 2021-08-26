#La imagen de base (:15 es la version de node)
FROM node:15
# no se obligatorio pero esto ya la dise da docker desde que carpeta se va a trabajar y no hace falta andar aclarandolo.
WORKDIR /app
# copia el package.json el . es el directorio en el que estamos, en este caso /app, si no hubieramos aclarado el 
# WORKDIR en ves de . tendriasmos que poner /app 
COPY package.json . 
# instala los dependencias 
#RUN npm install
#cundo estamos en produccion no queremos instalar las dependencias de desarrollo.
ARG NODE_ENV
RUN if [ "$NODE_ENV" = "development" ]; \
        then npm install; \
        else npm install --only=production; \
        fi
# copiamos el resto de archivos, . para copiar todo el directorio actual y el segundo punto es el directirio a salvar en 
# el contenedor en este caso en /app igual que en copy,
#se hace en este orden por que doker guarda toda la data en cache, si no hay cambios omite el paso.  
COPY  . ./
#agregar env
ENV PORT 3000
# en realidad es mas para documentacion en si no hace nada, no abre el puerto
#EXPOSE 3000
#como lo definimos en el env ponemos la variable par que se matenga actualizado si este cambia
EXPOSE $PORT
# ejecuta el comando node index.js
CMD ["node", "index.js"]
# ejecuta el comando npm run dev
#CMD [ "npm", "run", "dev" ]

# para construir la imagen ponemos en le consola "docker build ." (el punto es el la ubicacion del dockerfile, 
# en esete caso la misma carpeta )

# "docker image ls" lista toda las imagenes que tenemos
# "docker image rm <image-id>" para eliminar una imagen 
# "docker build -t <nombre de la imagen> <directorio del dockerfile>" para construir la imagen dandole un nombre.
# eje: docker build -t node-app-image .
# "docker run <nombre de la imagen>" para construir y correr el contenedor 
# a este comando se le pueden agregar algunas flags:
# "--name <nombre del contenedor>" para nombrar el contenedor 
# "-d" correr el contenedor en modo detach para tener libre la consola, si no no la podes usar (como cuando corres node?)
# eje: docker run -d --name node-app node-app-image
# "docker ps" para ver los contenedores que estan funcionando
# "docker rm <nombre del contenedor>" elimina el contenedor si le agregas el flag -f lo elimina sin la nesecidad de dentenerlo
# eje: docker rm node-app -f
#por defecto los contenedores pueden conectarse a internet pero no puden comunicarse con el mundo exterior ,
#para poder realmente exponer el puerto 3000 (o el que sea) hay que agregarle al run la flag -p 3000:3000 el primer 3000
# es el puerto de la pc el segundo el del contenedor, pueden ser distintos. 
# enronces quedari el run asi : "docker run -p 3000:3000 -d  --name node-app node-app-image"

#"docker exec -it <nombre del contenedor> bash" para acceder al bash del contenedro (-it es interective mode) 
# "exit" para salir.

#usamos un archivo .dockerignore para que el el copy no copie los archivos que no queremo en el contenedor 

#para poder tener sincronisado nuetros archivos locales con los archivos en el contenedor y no tener que andar recostrullendo 
#la imagen cada vez que realizamos un cambio podemos agregar el flag "-v <directorio local>:<directorio en contenedor>" en 
# en el comando docker run. eje:
# "dokcer run -v D:\Documents\aprendiendo web\docker con express\docker-express\:/app -p 3000:3000 -d --name node-app node-app-image" 
#para no tener que agregar todo el directorio local pode poner los siguientes shortcuts que devuelven el directiro que estad usando:
# en windows cmd "%cd%" 
#en windows powershell "${pwd}"
#en linux y mac "$(pwd)"
#eje: "docker run -v ${pwd}:/app -p 3000:3000 -d --name node-app node-app-image"
# la -v es de volume

#agrega nodemone como dependencia de desarrolo para no tener que reiniciar el servidor cada vez que hay un cambio

#"docker ps" solo mustra los contenedores que estan corriendo, si queres ver todos hay que agregarle la flag -a
#"docker ps -a"
#"docker logs <nombre del contenedor>" para ver los logs del contenedor 

#si corres el contenedor con "docker run -v ${pwd}:/app -p 3000:3000  -d --name node-app node-app-image" y 
#eleminas por ejemplo la carpeta node_modules en el directotio local, vas a romper el cotenedor por que al estar sincronizados 
#los directorios tambien lo esta eliminando del contenedor. para prevenir esto agregas al run otra flag
#"-v <directorio del contenedor que no deve estar sincronizado>" eje:
#"docker run -v ${pwd}:/app -v /app/node_modules -p 3000:3000  -d --name node-app node-app-image"

#por ahora cualquer cambio que realicemos en el contenedor tambien va a modificar nuestro directorio local. por ejemplo
#si creamos un archivo en el contenedor tambien se va a crear en nustro directorio local.
#para evitar esto podemos hacer el flag -v que sea solo de lectura. 
#"docker run -v ${pwd}:/app:ro -v /app/node_modules -p 3000:3000  -d --name node-app node-app-image"
#el ro es read only 
#de esta manera si queremos agregar un archivo desde el contenedor no nos va a dejar, lo tenemos que haser localmente 

#al run le podemos expesificar una env con le flag --env:
#docker run -v ${pwd}:/app -v /app/node_modules --env PORT=4000  -p 3000:4000 -d --name node-app node-app-image
#podes usar --env todas las veces que quieras para poner distintas variables de entorno, pero si tenes muchas es mejor 
#utilizar un archivo .env
#para eso agregar la flag "--env-file <ubicacion del archivo>". eje:
# docker run -v ${pwd}:/app -v /app/node_modules --env --env-file ./.env -p 3000:4000 -d --name node-app node-app-image

#"docker volume ls" para listar los volumes
#"docker volume rm <nombre del volume>" para elimininar uno
#"docker volume prune" purga los volumes

#cada vez que eliminas un contenedor con "doker rm  -f <nombre del contenedor>" no elimina el volumen asociado y crea 
#uno nuevo cuando crea otro contenedor.
#si queres eliminar el volumen junto al contenedor. "docker rm <nombre del contenedor> -fv"

#en ves de escribir todo el doker run largisimo, la cual es una molestia sobre todo si usas muchos contenedores, podes crear un 
# archivo doker-compose.yml el cual te permite automatizar la creacion de contenedores. 