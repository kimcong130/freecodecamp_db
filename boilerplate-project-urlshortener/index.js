require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
const bodyParser = require('body-parser');
const dns = require('dns');
let urlencodedParser = bodyParser.urlencoded({ extended: false })
// Basic Configuration
const port = process.env.PORT || 3000;
//id
let idSerial = 1;
let dbUrl = {};
let dbShortUrl = {};
app.use(cors());

app.use('/public', express.static(`${process.cwd()}/public`));


app.get('/', function(req, res) {
  res.sendFile(process.cwd() + '/views/index.html');
});

// Your first API endpoint
app.get('/api/hello', function(req, res) {
  res.json({ greeting: 'hello API' });
});


function isValidHttpUrl(string) {
  let url;

  try {
    url = new URL(string);
  } catch (err) {
    console.log(err)
    return false;
  }
  return url.protocol === "http:" || url.protocol === "https:";
}
app.post('/api/shorturl',urlencodedParser, (req, res) => {
  let url = req.body.url;
  console.log(url);
  console.log("post");
  if (!isValidHttpUrl(url)) {
    res.json({ error: 'invalid url' });
    return;
  }
  if (!dbUrl[url]) {
    dbUrl[url] = idSerial;
    dbShortUrl[idSerial] = url;
    idSerial++;
  } 

  res.json({
    "original_url": url,
    "short_url": dbUrl[url]
  })

});

//visit /api/shorturl/<short_url>
// redirected to the original URL.
app.get('/api/shorturl/:shorturl', (req, res) => {
  console.log(req.params.shorturl);
  console.log('get');
  const url = dbShortUrl[req.params.shorturl];
  if (url) {
    res.redirect(url);
  } else {
    res.json({"err": "Wrong format"});
  }
});


app.listen(port, function() {
  console.log(`Listening on port ${port}`);
});
