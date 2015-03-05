/**
 * Description:
 *   Share a "funny" joke with the channel. (Example of a hubot script written in Javascript)
 *
 * Dependencies:
 *   None
 *
 * Configuration:
 *   None
 *
 * Commands:
 *   hubot joke me - replies with a 'funny' joke
 */

module.exports = function (robot) {
  robot.respond(/joke me/i, function(msg) {
    console.log("Heard message: " + msg.message.text);
    var bad_jokes = [
      ["What's a robot's favourite film?", "Raiders of the Lost *Spark*!"],
      ["What's a robot's favourite book?", "Harry Potter and the Goblet of *Wire*!"],
      ["What web browser would a robot use?", "*Wire*-fox!"],
      ["Where does a robot go on holiday?", "The *Mech* Republic!"]
    ];
    var joke = msg.random(bad_jokes);
    msg.send(joke[0]);
    setTimeout(function() {
      msg.send(joke[1]);
    }, 2000);
    setTimeout(function() {
      msg.send("http://media.giphy.com/media/Xnhrfkfiawumk/giphy.gif");
    }, 3000);
  });
};
