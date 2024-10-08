const express = require('express')
const app = express()
const cors = require('cors')
const mongoose = require('mongoose')
const bodyParser = require('body-parser');
require('dotenv').config()

app.use(cors())
app.use(express.static('public'))
let urlencodedParser = bodyParser.urlencoded({ extended: false })
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/views/index.html')
});

//connet mongoose
mongoose.connect(process.env.URI)
        .then(() => {
          console.log('Database connection successful');
        })
        .catch(() => {
          console.log('Database connection error');
        });
//db
//create schema

let userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  }
});
let exerciseSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  description: String,
  duration: Number,
  date: Date

});

//exporting a model
let User = mongoose.model('User', userSchema);
let Exercise = mongoose.model('Exercise', exerciseSchema);


//post a new exercises
app.post('/api/users/:_id/exercises', urlencodedParser, async (req, res) => {
  console.log("post exercise");
  console.log(req.body);
  console.log(req.params['_id']);
  const userId = req.params['_id'];
  const inputDescription = req.body.description;
  const inputDuration = req.body.duration;
  let inputDate = req.body.date;
  if (inputDate) {
    inputDate = new Date(inputDate);
  } else {
    inputDate = new Date(Date.now());
  }
  console.log(userId, inputDescription, inputDuration, inputDate.toDateString());


  try {
    const user = await User.findById(userId);
    
    if (user) {
      const newExercise = new Exercise({
        name: user.name,
        description: inputDescription,
        duration: inputDuration,
        date: inputDate,
      });
      const saveExercise = await newExercise.save();
      
      return res.status(200).json({ 
                  _id: user._id,
                  username: saveExercise.name,
                  date: saveExercise.date.toDateString(),
                  duration: saveExercise.duration,
                  description: saveExercise.description
                 });

    } else {
      return res.status(404).json({ error: 'User not found' });
    }
  } catch (error) {
    return res.json({ error: error.message });
  }

})


//post a user name
app.post('/api/users', urlencodedParser, async (req, res) => {
  const userName = req.body.username; // Get the user name from the request body
  console.log("post user");
  console.log(userName);
  try {
    // Check if user already exists
    const existingUser = await User.findOne({ name: userName });
    
    if (existingUser) {
      // If user exists, return the existing user ID and name
      return res.status(200).json({  username: existingUser.name, _id: existingUser._id });
    }

    // If user does not exist, create a new one
    const newUser = new User({ name: userName });
    const savedUser = await newUser.save();

    // Send the newly created user ID and name
    return res.status(201).json({ username: savedUser.name, _id: savedUser._id });
  } catch (error) {
    // Handle errors
    return res.status(500).json({ error: error.message });
  }
});
//get users
app.get('/api/users', async(req, res) => {
  try {
    const allUsers = await User.find();
    const formatUeser = allUsers.map(user => ({
      username: user.name,
      _id: user._id
    }));
    return res.status(200).send(
      formatUeser
    ); 

  } catch(error) {
    res.status(500).json({error: error.message});
  }
})
//get log
app.get('/api/users/:_id/logs', async (req, res) => {
  const userId = req.params['_id'];
  const startDate  = req.query['from'];
  const endDate = req.query['to'];
  const docLimit = req.query['limit'];
  console.log("get log");
  console.log(userId, startDate, endDate, docLimit);
  try {
    const user = await User.findById(userId);
    console.log(user);
    if (user) {
      const query = { name: user.name};
      if (startDate) {
        query.date = { $gte: new Date(startDate)};
      }
      if (endDate) {
        query.date = {...query.date, $lte: new Date(endDate)};
      }
      const logs = await Exercise.find(query).limit(docLimit ? parseInt(docLimit) : 0);
      console.log(logs);
      const formattedLogs = logs.map(log => ({
        description: log.description,
        duration: log.duration,
        date: log.date.toDateString(),
      }));

      return res.status(200).json({
        _id: user._id,
        username: user.name,
        count: formattedLogs.length,
        log: formattedLogs,
      });
    } else {
      return res.status(404).json({ error: 'User not found' });
    }
  } catch (error) {
    console.log(error)
    return res.status(500).json({ error: "service error" }); 
  }
})
//listener
const listener = app.listen(process.env.PORT || 3000, () => {
  console.log('Your app is listening on port ' + listener.address().port)
})
