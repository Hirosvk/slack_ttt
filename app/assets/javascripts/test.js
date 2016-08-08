let defaultContent = {
  token: "gIkuvaNzQIHg97ATvDxqgjtO",
  team_id: "T0001",
  team_domain: "example",
  channel_id: "C2147483705",
  channel_name: "test",
  user_id: "U2147483697",
  user_name: "J",
  command: "/show_board",
  text: "",
  response_url: "https://hooks.slack.com/commands/1234/5678"
};
function parseContent(content){
  let formatted = "";
  for(let propName in content){
    formatted += propName + "=" +
                 content[propName] + "&";
  }
  return formatted.slice(0,formatted.length-1);
}
function makeAjaxCall(content, successCallback){
  let request = new XMLHttpRequest();
  request.open("POST", `https://hiro-slack-ttt.herokuapp.com/api/games${content.command}`, true);
  request.onload = function(resp){
    if (request.status === 200){
      responseContent(JSON.parse(request.responseText));
      if (successCallback) { successCallback(); }
      // all responses are with status:200
    } else {
      console.log(resp);
      if (successCallback) { successCallback(); }
    }
  }
  request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  request.send(parseContent(content));
};
function _makeAjaxCall(content, successCallback){
  let request = new XMLHttpRequest();
  request.open("POST", `http://localhost:3000/api/games${content.command}`, true);
  request.onload = function(resp){
    if (request.status === 200){
      responseContent(JSON.parse(request.responseText));
      if (successCallback) { successCallback(); }
      // all responses are with status:200
    } else {
      console.log(resp);
      if (successCallback) { successCallback(); }
    }
  }
  request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  request.send(parseContent(content));
};
function responseContent(a){console.log(a)}
