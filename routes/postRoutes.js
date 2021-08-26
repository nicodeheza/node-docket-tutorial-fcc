const express= require('express');

const postController= require('../controllers/postControler');
const protect= require('../middelware/authMiddelware');

const router= express.Router();

router.route('/')
.get(protect, postController.getAllPost)
.post( protect, postController.createPost);

router.route('/:id')
.get(protect, postController.getOnePost)
.patch( protect, postController.updatePost)
.delete( protect, postController.deletePost);

module.exports= router;