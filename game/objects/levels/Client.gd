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
var id = null
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
#var hostId :int
var lobbyValue = "-1"
var lobbyInfo = {}
var GameManager_TEMP = {"Players" = null}

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(RTCServerConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)
	
func RTCServerConnected():
	print_debug("RTC server connected")
	
func RTCPeerConnected(id):
	print_debug("rtc peer connected " + str(id))
	
func RTCPeerDisconnected(id):
	print_debug("rtc peer disconnected " + str(id))
	
func _process(delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var data = JSON.parse_string(packet.get_string_from_utf8())
			if data["message_type"] == MessageTypes.message:
				print_debug(data["data"])
			if data["message_type"] == MessageTypes.id:
				id = data["data"]
				$"../VBoxContainer/PeerId".text = "Peer id: " + str(id)
				print_debug("My id is: ", id)
				connected(id)
			if data["message_type"] == MessageTypes.userConnected:
				create_peer(data["id"])
				lobbyValue = data["lobbyValue"]
				$"../BackgroundImage/EnterLobbyId".text = lobbyValue
			if data["message_type"] == MessageTypes.lobby:
				GameManager_TEMP["Players"] = JSON.parse_string(data["players"])
			if data["message_type"] == MessageTypes.candidate:
				if rtcPeer.has_peer(data.orgPeer):
					print("Got Candididate: " + str(data["orgPeer"]) + " my id is " + str(id))
					rtcPeer.get_peer(data["orgPeer"]).connection.add_ice_candidate(data["mid"], data["index"], data["sdp"])
			if data["message_type"] == MessageTypes.offer:
				if rtcPeer.has_peer(data["orgPeer"]):
					rtcPeer.get_peer(data["orgPeer"]).connection.set_remote_description("offer", data["data"])
			if data["message_type"] == MessageTypes.answer:
				if rtcPeer.has_peer(data["orgPeer"]):
					rtcPeer.get_peer(data["orgPeer"]).connection.set_remote_description("answer", data["data"])

func _on_send_data_to_server_pressed():
	var message = {
"message_type" : MessageTypes.message,
"data": "test from client!"
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())


func create_lobby(lobby_id:String = ""):
	var message = {
"message_type" : MessageTypes.lobby,
"id" : id,
"name" : "",
"lobbyValue" : lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

#web rtc connection
func create_peer(peer_id):
	if peer_id != self.id:
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers" : [{ "urls": ["stun:stun.l.google.com:19302"] }] #!change this
		})
		print_debug("binding id " + str(peer_id) + " my id is " + str(self.id))
		
		peer.session_description_created.connect(self.offerCreated.bind(peer_id))
		peer.ice_candidate_created.connect(self.iceCandidateCreated.bind(peer_id))
		rtcPeer.add_peer(peer, peer_id)

		if peer_id < rtcPeer.get_unique_id():
			peer.create_offer()

func offerCreated(type, data, id):
	if !rtcPeer.has_peer(id):
		return
		
	rtcPeer.get_peer(id)["connection"].set_local_description(type, data)

	if type == "offer":
		sendOffer(id, data)
	else:
		sendAnswer(id, data)
	pass
	
func iceCandidateCreated(midName, indexName, sdpName, id):
	var message = {
		"message_type" : MessageTypes.candidate,
		"peer" : id,
		"orgPeer" : self.id,
		"mid": midName,
		"index": indexName,
		"sdp": sdpName,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	
func sendOffer(id, data):
	var message = {
		"message_type" : MessageTypes.offer,
		"peer" : id,
		"orgPeer" : self.id,
		"data": data,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	
func sendAnswer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message_type" : MessageTypes.answer,
		"data": data,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	
func connected(my_id):
	rtcPeer.create_mesh(my_id)
	multiplayer.multiplayer_peer = rtcPeer
	create_lobby(lobbyValue)
	$"../BackgroundImage/Info".visible = false
	
func _on_host_online_game_pressed():
	peer.create_client("ws://127.0.0.1:8918")
	$"../BackgroundImage/Info".text = "Connection to best avaliable server..."
	$"../BackgroundImage/Info".visible = true
	print_debug("here")


func _on_join_online_game_pressed():
	peer.create_client("ws://127.0.0.1:8918")
	lobbyValue = $"../BackgroundImage/EnterLobbyId".text
	$"../BackgroundImage/Info".text = "Connection to best avaliable server..."
	$"../BackgroundImage/Info".visible = true

@rpc("any_peer")
func update_number_of_player(number_of_players:int):
	$"../BackgroundImage/NumberOfOfflinePlayersSelector".value = number_of_players

func _on_number_of_offline_players_selector_value_changed(value):
	update_number_of_player.rpc(value)