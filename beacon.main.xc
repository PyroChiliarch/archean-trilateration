; Beacon position
const $x = 0
const $y = 0
const $z = 6203001.859879

; Beacons channel
; Mine are named after NASA's near space network
const $send_channel = "nsn_0"


update
	
	; Prepare data for transmission
	var $data = ""
	$data.x = $x
	$data.y = $y
	$data.z = $z
	
	; Add extra values to data here
	; eg
	; $data.battery = input_number("batt", 0)
	
	
	; Transmit data
	output_text(0, 0, $data)
	output_text(0, 1, $send_channel)
	
	; Display position and channel on screen
	blank(black)
	text_size(2)
	write(2, 2, white, "Channel: " & $send_channel)
	write(2, char_h + 2, white, "X: " & $x:text)
	write(2, char_h * 2 + 2, white, "Y: " & $y:text)
	write(2, char_h * 3 + 3, white, "Z: " & $z:text)
