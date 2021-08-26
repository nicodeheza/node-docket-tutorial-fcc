const express= require('express');
const mongoose= require('mongoose');
const session = require('express-session');
const redis= require('redis');
const cors= require('cors');
let RedisStore= require('connect-redis')(session);
const { MONGO_USER, MONGO_PASSWORD, MONGO_IP, MONGO_PORT, REDIS_URL, REDIS_PORT, SESSION_SECRET } = require('./config/config');

let redisClient= redis.createClient({
    host: REDIS_URL,
    port: REDIS_PORT
});
const postRouter= require('./routes/postRoutes');
const userRoutes= require('./routes/userRoutes');

const app= express();

//como docker crea una red podemos en vez de usar la ip podes usar el nombre del services como un dns. 
// docker logs <nombre del contenedor> -f //para seguir mostrando los logs  
const mongoURL= `mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_IP}:${MONGO_PORT}/?authSource=admin`;

//en caso de que no se pueda conectar a la db, por que no termino de iniciarse el contenedor lo reintenta cada 5 seg
function connectWithRetry(){
    mongoose.connect(mongoURL, {useNewUrlParser: true, useUnifiedTopology: true})
    .then(()=> console.log("succesfully connected to DB"))
    .catch((e)=> {
        console.log(e);
        setTimeout(connectWithRetry, 5000);
        }); 
}

connectWithRetry();

//para que agregue o confie en los headers que agrega nginx, aca no los usamos pero es bueno agregarlo cuando se usa un proxy 
//o por si necesitamos esos headers como el ip del cliente.  
app.enabled('trust proxy'); 

app.use(cors({}));

app.use(session({
    store: new RedisStore({client: redisClient}),
    secret: SESSION_SECRET,
    cookie:{
        secure: false,
        resave: false,
        saveUninitialized: false, 
        httpOnly: true,
        maxAge: 1000 * 30 
    }
}));

app.use(express.json());


app.get('/api/v1',(req, res)=>{
    console.log("yeah it ran");
    res.send("<h2>Hi There</h2>");
});
app.use('/api/v1/post', postRouter);
app.use('/api/v1/users', userRoutes)

const port= process.env.PORT || 3000;

app.listen(port, ()=> console.log('app listen on port: ' + port));