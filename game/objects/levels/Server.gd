extends Node

enum MessageTypes{
id,
join,
userConnected,
userDisconnected,
lobby,
candidate,
offer,
answer,
checkIn,
message
}

var peer = WebSocketMultiplayerPeer.new()
var users = {}
var lobbies = {}
var Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
@export var hostPort = 8918

# Called when the node enters the scene tree for the first time.
func _ready():
	if "--server" in OS.get_cmdline_args():
		print("hosting on " + str(hostPort))
		peer.create_server(hostPort)
	peer.connect("peer_connected", peer_connected)
	peer.connect("peer_disconnected", peer_disconnected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var data = JSON.parse_string(packet.get_string_from_utf8())
			if data["message_type"] == MessageTypes.message:
				print_debug(data["data"])
			if data["message_type"] == MessageTypes.lobby:
#				print_debug(data["id"], "\n",data["lobbyValue"])
				JoinLobby(data)
			if data["message_type"] == MessageTypes.offer || data["message_type"] == MessageTypes.answer || data["message_type"] == MessageTypes.candidate:
				print_debug("source id is " + str(data["orgPeer"]))
				sendToPlayer(data["peer"], data)

func createServer(port:int):
	peer.create_server(port)
#	$"../webRTC/ServerButton".disabled = true

#func _on_send_data_to_client_pressed():
#	var message = {
#		"message_type" : MessageTypes.message,
#		"data": "test from Server"
#	}
#	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func peer_connected(id):
	print_debug("Peer Connected with id: " + str(id))
	users[id] = {
		"message_type" : MessageTypes.id,
		"data" : id
	}
	peer.get_peer(id).put_packet(JSON.stringify(users[id]).to_utf8_buffer())
	
func peer_disconnected(id):
	users.erase(id)
	
func JoinLobby(user):
	var result = ""
	if user["lobbyValue"] == "-1":
		user["lobbyValue"] = generateRandomString()
		lobbies[user["lobbyValue"]] = lobby.new(user["id"])
		print(user["lobbyValue"])
	var player = lobbies[user["lobbyValue"]].AddPlayer(user["id"], user["name"])

	for p in lobbies[user.lobbyValue].Players:

		var data = {
			"message_type" : MessageTypes.userConnected,
			"id" : user["id"],
			"lobbyValue" : user["lobbyValue"]
		}
		sendToPlayer(p, data)

		var data2 = {
			"message_type" : MessageTypes.userConnected,
			"id" : p,
			"lobbyValue" : user["lobbyValue"]
		}
		sendToPlayer(user.id, data2)

		var lobbyInfo = {
			"message_type" : MessageTypes.lobby,
			"players" : JSON.stringify(lobbies[user["lobbyValue"]].Players),
#			"host" : lobbies[user.lobbyValue].HostID,
#			"lobbyValue" : user.lobbyValue
		}
		sendToPlayer(p, lobbyInfo)

	var data = {
		"message_type" : MessageTypes.userConnected,
		"id" : user["id"],
		"host" : lobbies[user["lobbyValue"]].HostID,
		"player" : lobbies[user["lobbyValue"]].Players[user["id"]],
		"lobbyValue" : user["lobbyValue"]
	}
	
	sendToPlayer(user["id"], data)
	
	
	
func sendToPlayer(userId, data):
	peer.get_peer(userId).put_packet(JSON.stringify(data).to_utf8_buffer())
	
func generateRandomString():
	var result = ""
	for i in range(32):
		var index = randi() % Characters.length()
		result += Characters[index]
	return result


func _on_create_server_temp_pressed():
	print("hosting on " + str(hostPort))
	peer.create_server(hostPort)
